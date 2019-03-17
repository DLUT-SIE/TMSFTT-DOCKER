FROM python:3

# Set environment variables

# Log messages will be immediately dumped to
# the standard output stream instead of being buffered
ENV PYTHONUNBUFFERED 1

# Copy dependencies file
COPY TMSFTT-BE/requirements.txt /

# Install dependencies
RUN pip install -r /requirements.txt

# Copy project
COPY TMSFTT-BE /

# Copy health checker
COPY wait-for-it.sh /

# Copy entrypoint.sh
COPY entrypoint.sh /
RUN chmod a+x /entrypoint.sh

WORKDIR /

EXPOSE 80
