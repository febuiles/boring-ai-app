from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from langchain.document_loaders import OnlinePDFLoader, WebBaseLoader
from langchain.vectorstores import Chroma
from langchain.embeddings import GPT4AllEmbeddings
from langchain import PromptTemplate
from langchain.llms import Ollama
from langchain.callbacks.manager import CallbackManager
from langchain.chains import RetrievalQA
import sys
import os

app = FastAPI()

class GenerateRequest(BaseModel):
    source_doc: str

@app.post("/generate")
async def generate_text(req: GenerateRequest):
    try:
        loader = WebBaseLoader(req.source_doc, header_template={
            'User-Agent': 'Fly.io Federico Builes v0.1, federico@fly.io',
        })
        data = loader.load()

        from langchain.text_splitter import RecursiveCharacterTextSplitter
        text_splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=0)
        all_splits = text_splitter.split_documents(data)

        vectorstore = Chroma.from_documents(documents=all_splits, embedding=GPT4AllEmbeddings())

        template = """Use the following pieces of context to answer the question at the end.
        If you don't know the answer, just say that you don't know, don't try to make up an answer.
        Use three sentences maximum and keep the answer as concise as possible.
        Don't say "according to the context" or similar in your answers
        {context}
        Question: {question}
        Helpful Answer:"""
        QA_CHAIN_PROMPT = PromptTemplate(
            input_variables=["context", "question"],
            template=template,
        )

        llm = Ollama(model="llama2:7b")
        qa_chain = RetrievalQA.from_chain_type(
            llm,
            retriever=vectorstore.as_retriever(),
            chain_type_kwargs={"prompt": QA_CHAIN_PROMPT},
        )

        results = {}
        results["total_revenue"] = qa_chain({"query": "What was the total revenue?"})
        results["gross_margin"] = qa_chain({"query": "What was the gross margin?"})
        results["net_income"] = qa_chain({"query": "What was the net income?"})
        results["op_ex"] = qa_chain({"query": "What were the operational expenses?"})
        results["op_inc"] = qa_chain({"query": "What was the operational income?"})
        results["taxes"] = qa_chain({"query": "How much money went to taxes?"})
        results["fcf"] = qa_chain({"query": "What can you tell me about the cashflow?"})

        return results
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
