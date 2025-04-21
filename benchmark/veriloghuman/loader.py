"""RTLLM: An Open-Source Benchmark for Design RTL Generation with Large Language Model
https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=10473904

We propose an open-source benchmark named RTLLM, for generating design RTL with 
natural language instructions. To systematically evaluate the auto-generated design RTL, we summarized three progressive goals, named syntax goal, functionality goal, and design quality goal. This benchmark can automatically provide a quantitative evaluation of any given LLM-based solution.

Homepage: https://github.com/hkust-zhiyao/RTLLM/tree/main
"""

import json
import datasets


_CITATION = """
@inproceedings{lu2024rtllm,
  title={RTLLM: An open-source benchmark for design rtl generation with large language model},
  author={Lu, Yao and Liu, Shang and Zhang, Qijun and Xie, Zhiyao},
  booktitle={2024 29th Asia and South Pacific Design Automation Conference (ASP-DAC)},
  pages={722--727},
  year={2024},
  organization={IEEE}
}
"""

_DESCRIPTION = """
Systematically evaluate the auto-generated design RTL. It has three progressive goals, named syntax goal, functionality goal, and design quality goal.
"""

# TODO: Add a link to an official homepage for the dataset here
_HOMEPAGE = ""

# TODO: Add the licence for the dataset here if you can find it
_LICENSE = ""

# TODO: Add link to the official dataset URLs here
# The HuggingFace Datasets library doesn't host the datasets but only points to the original files.
# This can be an arbitrary nested dict/list of URLs (see below in `_split_generators` method)
_URLS = {
    "first_domain": "",
    "second_domain": "",
}


class RTLLMDataset(datasets.GeneratorBasedBuilder):
    """RTLLM dataset, it has 29 samples for evaluation with syntax and functional passes."""

    VERSION = datasets.Version("1.0.0")
    META_DATA_VAL = "benchmark/verilogeval_human/val.jsonl"

    def _info(self):
        features = datasets.Features(
            {
                "exp_name": datasets.Value("string"),
            }
        )
        return datasets.DatasetInfo(
            description=_DESCRIPTION,
            features=features,  
            homepage=_HOMEPAGE,
            license=_LICENSE,
            citation=_CITATION,
        )

    def _split_generators(self, dl_manager):

        return [
            datasets.SplitGenerator(
                name=datasets.Split.VALIDATION,
                gen_kwargs={
                    "meta_data": self.META_DATA_VAL
                },
            )
        ]

    def _generate_examples(self, meta_data):
        with open(meta_data, encoding="utf-8") as f:
            for key, row in enumerate(f):
                data = json.loads(row)
                yield key, {
                    "exp_name": data["exp_name"],
                }