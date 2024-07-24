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
        Make Use three sentences maximum and keep the answer as concise as possible.
        {context}
        Question: {question}
        Helpful Answer:"""
        QA_CHAIN_PROMPT = PromptTemplate(
            input_variables=["context", "question"],
            template=template,
        )

        llm = Ollama(model="llama3")
        qa_chain = RetrievalQA.from_chain_type(
            llm,
            retriever=vectorstore.as_retriever(),
            chain_type_kwargs={"prompt": QA_CHAIN_PROMPT},
        )

        result = qa_chain({"query": "What was the gross margin?"})

        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
