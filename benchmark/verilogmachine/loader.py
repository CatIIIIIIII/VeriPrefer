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


class VEvalMachine(datasets.GeneratorBasedBuilder):

    VERSION = datasets.Version("1.0.0")
    META_DATA_VAL = "benchmark/verilogeval_machine/val.jsonl"

    def _info(self):
        features = datasets.Features(
            {
                "exp_name": datasets.Value("string"),
            }
        )
        return datasets.DatasetInfo(
            description=_DESCRIPTION,
            features=features,  
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