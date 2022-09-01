# using ubuntu LTS version
FROM ubuntu:20.04 AS builder-image

# avoid stuck build due to user prompt
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --no-install-recommends -y python3.9 python3.9-dev python3.9-venv python3-pip python3-wheel build-essential && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

# create and activate virtual environment
# using final folder name to avoid path issues with packages
RUN python3.9 -m venv /home/neshri/venv
ENV PATH="/home/neshri/venv/bin:$PATH"

# install requirements
COPY pipfile .
RUN pip3 install --no-cache-dir wheel
RUN pip3 install --no-cache-dir -r pipfile

FROM ubuntu:20.04 AS runner-image
RUN apt-get update && apt-get install --no-install-recommends -y python3.9 python3-venv && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home neshri
COPY --from=builder-image /home/neshri/venv /home/neshri/venv

USER neshri
RUN mkdir /home/neshri/code
WORKDIR /home/neshri/code
COPY . .

EXPOSE 5000

# make sure all messages always reach console
ENV PYTHONUNBUFFERED=1

# activate virtual environment
ENV VIRTUAL_ENV=/home/neshri/venv
ENV PATH="/home/neshri/venv/bin:$PATH"

