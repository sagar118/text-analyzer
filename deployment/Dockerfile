FROM public.ecr.aws/lambda/python:3.9

ARG MODEL_BUCKET
ARG EXPERIMENT_ID
ARG RUN_ID

ENV MODEL_BUCKET=$MODEL_BUCKET
ENV EXPERIMENT_ID=$EXPERIMENT_ID
ENV RUN_ID=$RUN_ID

RUN pip install -U pip
RUN pip install pipenv

COPY [ "Pipfile", "Pipfile.lock", "./" ]

RUN pipenv install --system --deploy

COPY ./app ${LAMBDA_TASK_ROOT}

CMD [ "main.handler" ]
