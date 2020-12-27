local scheme = 'default'
local json = require('json')
local log = require('log')
local server = require('http.server').new(nil, 8080)

-- storage
box.cfg {
    listen = 3301,
    log_format = 'plain'
    -- background = true,
    -- log = '1.log',
    -- pid_file = '1.pid'
}

box.once("bootstrap", function()
    local s = box.schema.space.create(scheme)
    s:format({ { name = 'key', type = 'string' }, { name = 'value', type = 'string' } })
    s:create_index('primary', { type = 'hash', parts = { 'key' } })
end)


-- handlers
local function get_handler(self)
    local key = self:stash('id')
    local entries = box.space[scheme]:select({ key }, { limit = 1 })

    if entries == nil or table.getn(entries) == 0 then
        return {
            status = 404,
            headers = { ['content-type'] = 'application/json' },
            body = json.encode({ message = 'key: \'' .. key .. '\' doesn\'t exist' })
        }
    else
        log.info(entries[1][2])
        return {
            status = 200,
            headers = { ['content-type'] = 'application/json' },
            body = entries[1][2]
        }
    end
end

local function delete_handler(self)
    local key = self:stash('id')
    local entries = box.space[scheme]:delete({ key }, { limit = 1 })

    if entries == nil then
        return {
            status = 404,
            headers = { ['content-type'] = 'application/json' },
            body = json.encode({ message = 'key: \'' .. key .. '\' doesn\'t exist' })
        }
    else
        return { status = 204 }
    end
end

local function post_handler(self)
    log.info(self)
    local body

    local function decode()
        body = json.encode(self:json())
    end

    if pcall(decode) then
    else
        return {
            status = 400,
            headers = { ['content-type'] = 'application/json' },
            body = json.encode({ message = 'incorrect json body' })
        }
    end

    local key = self:stash('id')
    local entries = box.space[scheme]:select({ key }, { limit = 1 })


    if entries == nil or table.getn(entries) == 0 then
        box.space[scheme]:insert { key, body }
        return {
            status = 200,
            headers = { ['content-type'] = 'application/json' },
            body = body
        }
    else
        return {
            status = 409,
            headers = { ['content-type'] = 'application/json' },
            body = json.encode({ message = 'key: \'' .. key .. '\' already exists' })
        }
    end
end

local function put_handler(self)
    log.info(self)
    local body

    local function decode()
        body = json.encode(self:json())
    end

    if pcall(decode) then
    else
        return {
            status = 400,
            headers = { ['content-type'] = 'application/json' },
            body = json.encode({ message = 'incorrect json body' })
        }
    end

    local key = self:stash('id')
    local entries = box.space[scheme]:select({ key }, { limit = 1 })

    if entries == nil or table.getn(entries) == 0 then
        return {
            status = 404,
            headers = { ['content-type'] = 'application/json' },
            body = json.encode({ message = 'key: \'' .. key .. '\' doesn\'t exist' })
        }
    else
        box.space[scheme]:put { key, body }
        return {
            status = 200,
            headers = { ['content-type'] = 'application/json' },
            body = body
        }
    end
end

server:route({ path = '/kv/:id', method = 'GET' }, get_handler)
server:route({ path = '/kv/:id', method = 'POST' }, post_handler)
server:route({ path = '/kv/:id', method = 'DELETE' }, delete_handler)
server:route({ path = '/kv/:id', method = 'PUT' }, put_handler)
server:start()