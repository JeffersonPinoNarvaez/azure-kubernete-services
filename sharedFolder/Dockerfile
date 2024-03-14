FROM python:3.6
WORKDIR /app
COPY requirements.txt /app
COPY app.py /app
RUN pip install -r ./requirements.txt
CMD ["python", "app.py"]~