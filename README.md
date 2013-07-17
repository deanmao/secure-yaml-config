# Secure YAML Config

YAML configuration manager that allows encrypted values using public key
encryption.

## Usage

```yaml
development:
  username: john
  password: whatever

production:
  username: john
  password: decrypt(zzzzzzzzzzzzzzz)
```

```javascript
var manager = require('secure-yaml-config');
var config = manager.getConfig({
  publicKeyFile: 'public_key',
  configFile: 'config.yml',
  env: 'development'
});

service.connect(config.username, config.password);
```

