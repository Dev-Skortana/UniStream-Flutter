# Start with a lightweight base image
FROM hibitdev/sqlite:latest
 
# Install SQLite
RUN apk update && apk add sqlite
 
# Set the default working directory
WORKDIR /db
COPY ../assets/raw/Database_UniStream.db /db/
# Set the default command to open SQLite
CMD [""]