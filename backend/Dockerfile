FROM python:latest

#ENV PYTHONDONTWRITEBYTECODE=true

WORKDIR /apps/backend

COPY backend/requirements.txt /apps/backend
COPY backend/backend.py /apps/backend
COPY backend/backend.secret /apps/backend

RUN pip3 install -r requirements.txt

EXPOSE 8060

ENTRYPOINT ["gunicorn", "--workers", "2", "--timeout", "120", "--bind", "0.0.0.0:8060", "--pythonpath", ".", "backend:app"]
