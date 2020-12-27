# Tarantool KV-storage with http API

#### Implements the following API:
 - `GET /kv/{id}` 
 - `POST /kv/{id}` 
 - `PUT /kv/{id}`
 - `DELETE /kv/{id}`

#### For `PUT` and `POST` requests JsonBody is required.
#### Starts on `8080` port by default.
#### Use `docker compose up` to run the app.