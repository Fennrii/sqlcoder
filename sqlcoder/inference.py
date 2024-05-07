import torch
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
import argparse

class SQLCoder:
    def __init__(self, model_name):
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        self.model = AutoModelForCausalLM.from_pretrained(
            model_name,
            trust_remote_code=True,
            torch_dtype=torch.float16,
            device_map="auto",
            use_cache=True,
        )
        self.pipe = pipeline(
            "text-generation",
            model=self.model,
            tokenizer=self.tokenizer,
            max_new_tokens=300,
            do_sample=False,
            return_full_text=False, 
            num_beams=4,
        )

    def generate_prompt(self, question, prompt_file="/root/sqlcoder/prompt.md", metadata_file="/root/sqlcoder/metadata.sql"):
        with open(prompt_file, "r") as f:
            prompt = f.read()
        
        with open(metadata_file, "r") as f:
            table_metadata_string = f.read()

        prompt = prompt.format(
            user_question=question, table_metadata_string=table_metadata_string
        )
        return prompt

    def run_inference(self, question):
        prompt = self.generate_prompt(question)
        eos_token_id = self.tokenizer.eos_token_id
        generated_query = (
            self.pipe(
                prompt,
                num_return_sequences=1,
                eos_token_id=eos_token_id,
                pad_token_id=eos_token_id,
            )[0]["generated_text"]
            .split(";")[0]
            .split("```")[0]
            .strip()
            + ";"
        )
        return generated_query

if __name__ == "__main__":
    _default_question = "Do we get more sales from customers in New York compared to customers in San Francisco? Give me the total sales for each city, and the difference between the two."
    parser = argparse.ArgumentParser(description="Run inference on a question")
    parser.add_argument("-q", "--question", type=str, default=_default_question, help="Question to run inference on")
    args = parser.parse_args()
    sql_coder = SQLCoder("defog/sqlcoder-7b-2")
    print(sql_coder.run_inference(args.question))
