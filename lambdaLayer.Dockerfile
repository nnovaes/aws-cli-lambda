FROM python:3.8-slim-buster

ENV PYTHON_VERSION 3.8
ENV LAMBDA_LAYER_DIR awscli-lambda-layer
ENV ZIP_FILE_NAME awscli-lambda-layer.zip
ENV VIRTUAL_ENV_DIR /awscli-virtualenv

RUN apt-get update && \
    apt-get install zip -y && \
    mkdir $VIRTUAL_ENV_DIR && \
    python3 -m venv $VIRTUAL_ENV_DIR
ENV PATH="$VIRTUAL_ENV_DIR/bin:$PATH"
RUN cd ${VIRTUAL_ENV_DIR}/bin/ && \
    pip install awscli && \
    sed -i "1s/.*/\#\!\/var\/lang\/bin\/python/" aws && \
    cd ../.. && \
    mkdir ${LAMBDA_LAYER_DIR} && \
    cd ${LAMBDA_LAYER_DIR} && \
    cp ../${VIRTUAL_ENV_DIR}/bin/aws . && \
    cp -r ../${VIRTUAL_ENV_DIR}/lib/python${PYTHON_VERSION}/site-packages/* . && \
    zip -r ../${ZIP_FILE_NAME} *


FROM alpine
COPY --from=0 awscli-lambda-layer.zip .
