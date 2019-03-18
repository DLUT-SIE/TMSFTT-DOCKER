FROM python:3

# Set environment variables

# Log messages will be immediately dumped to
# the standard output stream instead of being buffered
ENV PYTHONUNBUFFERED 1

# Copy dependencies file
COPY TMSFTT-BE/requirements.txt /

# Install dependencies
RUN pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r /requirements.txt

# Copy health checker
COPY wait-for-it.sh /

# Copy entrypoint.sh
COPY entrypoint.sh /
RUN chmod a+x /entrypoint.sh

# COPY uwsgi config file
COPY uwsgi.ini /

# Copy project
COPY TMSFTT-BE /

WORKDIR /

EXPOSE 8080
