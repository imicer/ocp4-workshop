# Ignition

1. Install CoreOS transpiler tool.

```
./ct-installer.sh
```

2. Generate Ignition file.

```
ct \
  -in-file ignition-example.yml \
  -out-file ignition-example.json \
  -pretty
```

## References

- https://github.com/coreos/container-linux-config-transpiler
