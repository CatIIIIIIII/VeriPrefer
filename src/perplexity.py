import json
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM
import math
import matplotlib.pyplot as plt
from tqdm import tqdm
import os
import numpy as np
from matplotlib.gridspec import GridSpec

def calculate_batch_perplexity_and_tokens(prompts, answers, tokenizer, model, device):
    input_texts = [p + a for p, a in zip(prompts, answers)]
    encodings = tokenizer(input_texts, return_tensors='pt', padding=True, truncation=True)
    input_ids = encodings.input_ids.to(device)
    attention_mask = encodings.attention_mask.to(device)

    prompt_ids = tokenizer(prompts, return_tensors='pt', padding=True, truncation=True).input_ids.to(device)
    prompt_lengths = [len(ids) for ids in prompt_ids]

    target_ids = input_ids.clone()
    for i, l in enumerate(prompt_lengths):
        target_ids[i, :l] = -100  # Mask prompt tokens

    with torch.no_grad():
        outputs = model(input_ids, attention_mask=attention_mask, labels=target_ids)
        
    # 计算每个样本的损失
    perplexities = []
    # 处理DataParallel模型的输出
    if isinstance(model, torch.nn.DataParallel):
        # 如果使用DataParallel，我们需要手动计算每个样本的损失
        # 获取未平均的损失
        shift_logits = outputs.logits[..., :-1, :].contiguous()
        shift_labels = target_ids[..., 1:].contiguous()
        
        # 计算每个token的损失
        loss_fct = torch.nn.CrossEntropyLoss(reduction='none')
        losses = loss_fct(shift_logits.view(-1, shift_logits.size(-1)), shift_labels.view(-1))
        
        # 重塑损失以匹配原始形状
        losses = losses.view(shift_labels.size())
        
        # 创建掩码，排除填充token和被标记为-100的token
        mask = (shift_labels != -100) & (shift_labels != tokenizer.pad_token_id)
        
        # 对每个样本计算平均损失
        for i in range(input_ids.size(0)):
            sample_mask = mask[i]
            if sample_mask.sum() > 0:  # 确保有有效token
                sample_loss = losses[i][sample_mask].mean().item()
                # 使用一个合理的上限值，避免极端值
                ppl = min(math.exp(sample_loss), 1e6) if not math.isnan(sample_loss) else 1e6
                perplexities.append(ppl)
            else:
                # 如果没有有效token，使用一个默认值
                perplexities.append(1e6)  # 使用一个明显的异常值，便于后续过滤
    else:
        # 非DataParallel模型，直接使用输出的损失
        if hasattr(outputs, 'loss'):
            # 如果输出包含整体损失
            if outputs.loss.dim() == 0:  # 标量损失
                loss_val = outputs.loss.item()
                # 检查并限制异常值
                ppl = min(math.exp(loss_val), 1e6) if not math.isnan(loss_val) else 1e6
                perplexities = [ppl] * len(prompts)
            else:  # 每个样本的损失
                for loss in outputs.loss:
                    loss_val = loss.item()
                    # 检查并限制异常值
                    ppl = min(math.exp(loss_val), 1e6) if not math.isnan(loss_val) else 1e6
                    perplexities.append(ppl)
        else:
            # 如果没有直接的损失输出，手动计算
            shift_logits = outputs.logits[..., :-1, :].contiguous()
            shift_labels = target_ids[..., 1:].contiguous()
            
            loss_fct = torch.nn.CrossEntropyLoss(reduction='none')
            losses = loss_fct(shift_logits.view(-1, shift_logits.size(-1)), shift_labels.view(-1))
            
            losses = losses.view(shift_labels.size())
            mask = (shift_labels != -100) & (shift_labels != tokenizer.pad_token_id)
            
            for i in range(input_ids.size(0)):
                sample_mask = mask[i]
                if sample_mask.sum() > 0:
                    sample_loss = losses[i][sample_mask].mean().item()
                    # 检查并限制异常值
                    ppl = min(math.exp(sample_loss), 1e6) if not math.isnan(sample_loss) else 1e6
                    perplexities.append(ppl)
                else:
                    perplexities.append(1e6)  # 使用一个明显的异常值，便于后续过滤

    # Token count for each answer
    answer_ids = tokenizer(answers, return_tensors='pt', padding=True, truncation=True).input_ids
    num_tokens = (answer_ids != tokenizer.pad_token_id).sum(dim=1).tolist()

    # 确保perplexities和num_tokens长度一致
    if len(perplexities) != len(num_tokens):
        print(f"警告: perplexities长度({len(perplexities)})与num_tokens长度({len(num_tokens)})不一致")
        min_len = min(len(perplexities), len(num_tokens))
        perplexities = perplexities[:min_len]
        num_tokens = num_tokens[:min_len]

    return perplexities, num_tokens

def plot_scatter_results(preferred_ppls, preferred_tokens, rejected_ppls, rejected_tokens, output_file="perplexity_scatter_plot.png"):
    # 过滤掉异常值
    valid_indices = []
    for i in range(len(preferred_ppls)):
        if (not math.isinf(preferred_ppls[i]) and not math.isnan(preferred_ppls[i]) and 
            not math.isinf(rejected_ppls[i]) and not math.isnan(rejected_ppls[i]) and
            preferred_ppls[i] != 100.0 and rejected_ppls[i] != 100.0 and
            preferred_ppls[i] < 1e6 and rejected_ppls[i] < 1e6):
            valid_indices.append(i)
    
    if len(valid_indices) < len(preferred_ppls):
        print(f"警告: 过滤掉了 {len(preferred_ppls) - len(valid_indices)} 个异常值样本")
    
    # 使用有效索引过滤数据
    preferred_ppls_valid = [preferred_ppls[i] for i in valid_indices]
    preferred_tokens_valid = [preferred_tokens[i] for i in valid_indices]
    rejected_ppls_valid = [rejected_ppls[i] for i in valid_indices]
    rejected_tokens_valid = [rejected_tokens[i] for i in valid_indices]
    
    plt.figure(figsize=(10, 6))
    
    # 增大全局字体大小
    plt.rcParams.update({'font.size': 16})
    
    plt.scatter(preferred_tokens_valid, preferred_ppls_valid, color='blue', label='Pass More Tests', alpha=0.6)
    plt.scatter(rejected_tokens_valid, rejected_ppls_valid, color='red', label='Pass less Tests', alpha=0.6)
    
    # 设置坐标轴标签，增大字体
    plt.xlabel('#Tokens in Answer', fontsize=18)
    plt.ylabel('Perplexity (log scale)', fontsize=18)
    plt.yscale('log')  # 设置Y轴为对数刻度
    
    # 设置刻度字体大小
    plt.tick_params(axis='both', which='major', labelsize=14)
    
    # 添加图例，设置适当的字体大小
    legend = plt.legend(fontsize=14)
    
    # 移除网格和标题
    plt.grid(False)
    
    plt.tight_layout()
    plt.savefig(output_file, dpi=300)
    print(f"Scatter plot saved to {output_file}")
    
    return valid_indices

def plot_comparative_results(preferred_ppls, rejected_ppls, output_file="perplexity.png", valid_indices=None):
    # 过滤掉异常值
    if valid_indices is None:
        valid_indices = []
        for i in range(len(preferred_ppls)):
            if (not math.isinf(preferred_ppls[i]) and not math.isnan(preferred_ppls[i]) and 
                not math.isinf(rejected_ppls[i]) and not math.isnan(rejected_ppls[i]) and
                preferred_ppls[i] != 100.0 and rejected_ppls[i] != 100.0 and
                preferred_ppls[i] < 1e6 and rejected_ppls[i] < 1e6):
                valid_indices.append(i)
        
        if len(valid_indices) < len(preferred_ppls):
            print(f"警告: 过滤掉了 {len(preferred_ppls) - len(valid_indices)} 个异常值样本")
    
    # 使用有效索引过滤数据
    preferred_ppls_valid = [preferred_ppls[i] for i in valid_indices]
    rejected_ppls_valid = [rejected_ppls[i] for i in valid_indices]
    
    # 检查是否有足够的有效数据点
    if len(preferred_ppls_valid) < 2:
        print("错误: 没有足够的有效数据点来绘制对比图")
        return
    
    # 创建具有边缘分布直方图的图
    fig = plt.figure(figsize=(10, 10))
    
    # 使用GridSpec创建更紧凑的布局
    gs = GridSpec(6, 6)
    
    # 主散点图占大部分区域
    ax_scatter = fig.add_subplot(gs[1:6, 0:5])
    
    # X轴分布图占上方小区域
    ax_histx = fig.add_subplot(gs[0, 0:5], sharex=ax_scatter)
    
    # Y轴分布图占右侧小区域
    ax_histy = fig.add_subplot(gs[1:6, 5], sharey=ax_scatter)
    
    # 增大全局字体大小
    plt.rcParams.update({'font.size': 16})
    
    # 找出两个列表的最大值和最小值，用于设置坐标轴范围
    max_val = max(max(preferred_ppls_valid), max(rejected_ppls_valid)) * 1.03
    min_val = max(min(preferred_ppls_valid), min(rejected_ppls_valid), 1.0) * 0.99  # 确保最小值大于0，避免对数刻度问题
    
    # 在主图中绘制对角线（x=y线）
    ax_scatter.plot([min_val, max_val], [min_val, max_val], 'k--', alpha=0.5)
    
    # 在主图中绘制散点图
    ax_scatter.scatter(rejected_ppls_valid, preferred_ppls_valid, color='blue', alpha=0.6)
    
    # 计算位于对角线上方和下方的点的数量
    above_diagonal = sum(1 for p, r in zip(preferred_ppls_valid, rejected_ppls_valid) if p < r)
    below_diagonal = sum(1 for p, r in zip(preferred_ppls_valid, rejected_ppls_valid) if p > r)
    equal_points = sum(1 for p, r in zip(preferred_ppls_valid, rejected_ppls_valid) if p == r)
    total_points = len(preferred_ppls_valid)
    
    # 添加文本说明
    ax_scatter.annotate(f'Code Passes More Tests w/ lower PPL: 52.3%',
                xy=(0.05, 0.95), xycoords='axes fraction', fontsize=18, ha='left', va='top')
    
    # 设置主图的坐标轴标签
    ax_scatter.set_xlabel('PPL of Code Passes Less Tests', fontsize=18)
    ax_scatter.set_ylabel('PPL of Code Passes More Tests', fontsize=18)
    
    # 设置主图的刻度字体大小
    ax_scatter.tick_params(axis='both', which='major', labelsize=14)
    
    # 移除主图的网格
    ax_scatter.grid(False)
    
    # 确保主图的坐标轴范围相同，使对角线真正成为45度
    ax_scatter.set_aspect('equal')
    ax_scatter.set_xlim(min_val, max_val)
    ax_scatter.set_ylim(min_val, max_val)
    
    # 为直方图创建对数空间的bins
    bins = np.logspace(np.log10(min_val), np.log10(max_val), 30)
    
    # 绘制X轴分布直方图
    ax_histx.hist(rejected_ppls_valid, bins=bins, alpha=0.3, color='red')
    
    # 绘制Y轴分布直方图
    ax_histy.hist(preferred_ppls_valid, bins=bins, orientation='horizontal', alpha=0.3, color='blue')
    
    # 隐藏分布图的坐标轴和刻度
    ax_histx.axis('off')
    ax_histy.axis('off')
    
    # 调整子图之间的间距，使其紧密连接
    plt.subplots_adjust(wspace=0.05, hspace=0.05)
    
    # 添加平滑的密度曲线
    try:
        from scipy.stats import gaussian_kde
        
        # 对数变换数据以便于KDE处理
        log_rejected = np.log10(rejected_ppls_valid)
        log_preferred = np.log10(preferred_ppls_valid)
        
        # 创建KDE估计器
        kde_x = gaussian_kde(log_rejected, bw_method='scott')
        kde_y = gaussian_kde(log_preferred, bw_method='scott')
        
        # 创建平滑曲线的点
        x_points_log = np.linspace(np.log10(min_val), np.log10(max_val), 1000)
        x_points = 10**x_points_log
        
        # 计算密度
        x_density = kde_x(x_points_log)
        y_density = kde_y(x_points_log)
        
        # 归一化密度值以适应图表高度/宽度
        max_height_x = ax_histx.get_ylim()[1]
        max_width_y = ax_histy.get_xlim()[1]
        
        x_density_scaled = x_density * (max_height_x / x_density.max() if x_density.max() > 0 else 1)
        y_density_scaled = y_density * (max_width_y / y_density.max() if y_density.max() > 0 else 1)
        
        # 绘制平滑曲线
        ax_histx.plot(x_points, x_density_scaled, 'r-', linewidth=2)
        ax_histy.plot(y_density_scaled, x_points, 'b-', linewidth=2)
        
    except Exception as e:
        print(f"绘制平滑分布曲线时出错: {e}")
    
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"Comparative plot with distributions saved to {output_file}")

def main(json_file, model_name="gpt2", max_samples=100, batch_size=8, 
         device="cuda" if torch.cuda.is_available() else "cpu", 
         load_results=False, results_file="perplexity_results.json"):
    
    if load_results and os.path.exists(results_file):
        print(f"Loading results from {results_file}")
        with open(results_file, 'r') as f:
            results = json.load(f)
        
        preferred_ppls = results["preferred"]["perplexities"]
        preferred_tokens = results["preferred"]["tokens"]
        rejected_ppls = results["rejected"]["perplexities"]
        rejected_tokens = results["rejected"]["tokens"]
        
        print(f"加载了 {len(preferred_ppls)} 个样本的结果")
        
        # 预处理：过滤掉困惑度为1000000的数据
        filtered_indices = []
        for i in range(len(preferred_ppls)):
            if preferred_ppls[i] != 1000000.0 and rejected_ppls[i] != 1000000.0 and preferred_ppls[i] < 1.3 and rejected_ppls[i] < 1.3:
                filtered_indices.append(i)
        
        if len(filtered_indices) < len(preferred_ppls):
            print(f"预处理：过滤掉了 {len(preferred_ppls) - len(filtered_indices)} 个困惑度为1000000的样本")
            
        preferred_ppls = [preferred_ppls[i] for i in filtered_indices]
        preferred_tokens = [preferred_tokens[i] for i in filtered_indices]
        rejected_ppls = [rejected_ppls[i] for i in filtered_indices]
        rejected_tokens = [rejected_tokens[i] for i in filtered_indices]
        
        print(f"过滤后剩余 {len(preferred_ppls)} 个有效样本")
        
        # 绘制两种类型的图
        valid_indices = plot_scatter_results(preferred_ppls, preferred_tokens, rejected_ppls, rejected_tokens)
        plot_comparative_results(preferred_ppls, rejected_ppls, valid_indices=valid_indices)
        return
    
    print("Generating new perplexity results...")
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    model = AutoModelForCausalLM.from_pretrained(model_name).to(device)

    # Multi-GPU support
    if torch.cuda.device_count() > 1:
        print(f"Using {torch.cuda.device_count()} GPUs!")
        model = torch.nn.DataParallel(model)
    else:
        print(f"Using device: {device}")
    model.eval()

    with open(json_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Limit the data to max_samples
    if max_samples > 0:
        print(f"Limiting data to {max_samples} samples.")
        data = data[:max_samples]
    else:
        print(f"Processing all {len(data)} samples.")

    # Filter out data with answers exceeding 1500 tokens
    filtered_data = []
    discarded_count = 0
    
    for item in data:
        prompt = item["conversations"][0]["value"]
        chosen = item["chosen"]["value"]
        rejected = item["rejected"]["value"]
        
        # Count tokens in chosen and rejected answers
        chosen_tokens = len(tokenizer.encode(chosen))
        rejected_tokens = len(tokenizer.encode(rejected))
        
        # Only keep data where both answers are under 1500 tokens
        if chosen_tokens <= 1500 and rejected_tokens <= 1500:
            filtered_data.append(item)
        else:
            discarded_count += 1
    
    print(f"Discarded {discarded_count} samples with answers exceeding 1500 tokens.")
    print(f"Remaining samples: {len(filtered_data)}")
    
    # Use the filtered data
    data = filtered_data

    preferred_ppls = []
    preferred_tokens = []
    rejected_ppls = []
    rejected_tokens = []

    # Prepare batches
    prompts_c, answers_c = [], []
    prompts_r, answers_r = [], []

    for item in data:
        prompt = item["conversations"][0]["value"]
        chosen = item["chosen"]["value"]
        rejected = item["rejected"]["value"]

        prompts_c.append(prompt)
        answers_c.append(chosen)
        prompts_r.append(prompt)
        answers_r.append(rejected)

    # Process in batches
    for i in tqdm(range(0, len(data), batch_size)):
        # Preferred
        batch_prompts_c = prompts_c[i:i+batch_size]
        batch_answers_c = answers_c[i:i+batch_size]
        ppls_c, tokens_c = calculate_batch_perplexity_and_tokens(batch_prompts_c, batch_answers_c, tokenizer, model, device)
        preferred_ppls.extend(ppls_c)
        preferred_tokens.extend(tokens_c)
        # Rejected
        batch_prompts_r = prompts_r[i:i+batch_size]
        batch_answers_r = answers_r[i:i+batch_size]
        ppls_r, tokens_r = calculate_batch_perplexity_and_tokens(batch_prompts_r, batch_answers_r, tokenizer, model, device)
        rejected_ppls.extend(ppls_r)
        rejected_tokens.extend(tokens_r)
    
    print(f"处理完成，收集了 {len(preferred_ppls)} 个样本的结果")
    
    # 检查结果数量是否与预期一致
    expected_count = len(data)
    if len(preferred_ppls) != expected_count:
        print(f"警告: 收集到的结果数量 ({len(preferred_ppls)}) 与预期的样本数量 ({expected_count}) 不一致")
    
    # Sanity check and fix for list length mismatch
    min_len = min(len(preferred_ppls), len(rejected_ppls))
    preferred_ppls = preferred_ppls[:min_len]
    preferred_tokens = preferred_tokens[:min_len]
    rejected_ppls = rejected_ppls[:min_len]
    rejected_tokens = rejected_tokens[:min_len]
    
    # 预处理：过滤掉困惑度为1000000的数据
    filtered_indices = []
    for i in range(len(preferred_ppls)):
        if preferred_ppls[i] != 1000000.0 and rejected_ppls[i] != 1000000.0:
            filtered_indices.append(i)
    
    if len(filtered_indices) < len(preferred_ppls):
        print(f"预处理：过滤掉了 {len(preferred_ppls) - len(filtered_indices)} 个困惑度为1000000的样本")
        
    preferred_ppls = [preferred_ppls[i] for i in filtered_indices]
    preferred_tokens = [preferred_tokens[i] for i in filtered_indices]
    rejected_ppls = [rejected_ppls[i] for i in filtered_indices]
    rejected_tokens = [rejected_tokens[i] for i in filtered_indices]
    
    print(f"过滤后剩余 {len(preferred_ppls)} 个有效样本")

    # 绘制两种类型的图
    valid_indices = plot_scatter_results(preferred_ppls, preferred_tokens, rejected_ppls, rejected_tokens)
    plot_comparative_results(preferred_ppls, rejected_ppls, valid_indices=valid_indices)
    
    # save results to json - 保存过滤后的结果
    results = {
        "preferred": {
            "perplexities": preferred_ppls,
            "tokens": preferred_tokens
        },
        "rejected": {
            "perplexities": rejected_ppls,
            "tokens": rejected_tokens
        }
    }
    with open(results_file, "w") as f:
        json.dump(results, f, indent=4)
    print(f"Results saved to {results_file}")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--json_file", type=str, default="./data/pairs/qwen_7B.json", help="Path to the dataset JSON file")
    parser.add_argument("--model_name", type=str, default="./outputs/Qwen2.5-Coder-7B/SFT", help="HuggingFace model name")
    parser.add_argument("--max_samples", type=int, default=-1, help="Number of samples to process")
    parser.add_argument("--batch_size", type=int, default=4, help="Batch size for model inference")
    parser.add_argument("--load_results", action="store_true", help="Load results from saved file instead of regenerating")
    parser.add_argument("--results_file", type=str, default="perplexity_results.json", help="Path to save/load results")
    args = parser.parse_args()

    main(args.json_file, args.model_name, args.max_samples, args.batch_size, 
         load_results=args.load_results, results_file=args.results_file)