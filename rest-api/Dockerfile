FROM python:3

# Set environment variables

# Log messages will be immediately dumped to
# the standard output stream instead of being buffered
ENV PYTHONUNBUFFERED 1

# Copy dependencies file
COPY TMSFTT-BE/requirements.txt /

# Install dependencies
RUN pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r /requirements.txt

# Add support for TZ
RUN apt-get update
RUN apt-get install tzdata
RUN rm -rf /var/cache/apk/*

# Copy health checker
COPY wait-for-it.sh /

# COPY uwsgi config file
COPY uwsgi.ini /

# Copy project
COPY TMSFTT-BE /

# Create touch-reload file
RUN touch /uwsgi-touch-reload

WORKDIR /