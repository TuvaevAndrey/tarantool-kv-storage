# Tarantool KV-storage with REST API

#### Implements the following API:
 - `GET /kv/{id}` 
 - `POST /kv/{id}` 
 - `PUT /kv/{id}`
 - `DELETE /kv/{id}`

#### For `PUT` and `POST` requests JsonBody is required.
#### Starts on `8080` port by default.
#### To run the app:
 -  clone repository
 - `docker build -t trntl .`
 - `docker run -p 8080:8080 -it --rm trntl`
