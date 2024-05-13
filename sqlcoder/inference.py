import torch
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
import argparse

def generate_prompt(question, previous_error='', prompt_file="/root/sqlcoder/sqlcoder/prompt.md", metadata_file="/root/sqlcoder/sqlcoder/metadata.sql"):
    with open(prompt_file, "r") as f:
        prompt = f.read()
    
    with open(metadata_file, "r") as f:
        table_metadata_string = f.read()

    prompt = prompt.format(
        user_question=question, table_metadata_string=table_metadata_string, error=previous_error
    )
    return prompt


def get_tokenizer_model(model_name):
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    model = AutoModelForCausalLM.from_pretrained(
        model_name,
        trust_remote_code=True,
        torch_dtype=torch.float16,
        device_map="auto",
        use_cache=True,
    )
    return tokenizer, model

def run_inference(question, previous_error='', prompt_file="/root/sqlcoder/sqlcoder/prompt.md", metadata_file="/root/sqlcoder/sqlcoder/metadata.sql"):
    tokenizer, model = get_tokenizer_model("defog/llama-3-sqlcoder-8b")
    # tokenizer, model = get_tokenizer_model("defog/sqlcoder-70b-alpha") # Needs more than 50 gigs of storage to save tensors
    prompt = generate_prompt(question, previous_error, prompt_file, metadata_file)
    
    # make sure the model stops generating at triple ticks
    # eos_token_id = tokenizer.convert_tokens_to_ids(["```"])[0]
    eos_token_id = tokenizer.eos_token_id
    pipe = pipeline(
        "text-generation",
        model=model,
        tokenizer=tokenizer,
        max_new_tokens=300,
        do_sample=False,
        return_full_text=False, # added return_full_text parameter to prevent splitting issues with prompt
        num_beams=4, # do beam search with 5 beams for high quality results
    )
    generated_query = (
        pipe(
            prompt,
            num_return_sequences=1,
            temperature=0,
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
    # Parse arguments
    _default_question="How many patients are there?"
    parser = argparse.ArgumentParser(description="Run inference on a question")
    parser.add_argument("-q","--question", type=str, default=_default_question, help="Question to run inference on")
    args = parser.parse_args()
    question = args.question
    print(run_inference(question))
