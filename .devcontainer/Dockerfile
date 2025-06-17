FROM python:3.12-slim

RUN apt-get update && apt-get install -y \
    wget \
    git \
    gnupg \
    software-properties-common \
    direnv

# Install the HashiCorp GPG key.
RUN wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

# Verify the key's fingerprint.
RUN gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint

RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/hashicorp.list

RUN apt update && apt-get install terraform

RUN echo 'eval "$(direnv hook bash)"' >> /root/.bashrc

WORKDIR /app

COPY .devcontainer/requirements.txt .

RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

COPY . .

# .envrcが存在すれば事前にallow（初回起動時の手間削減）
RUN if [ -f .envrc ]; then direnv allow; fi

CMD ["bash"]
