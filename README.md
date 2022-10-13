<p align="center">
    <img src="resources/img/logo.png" height="200">
</p>
<div align="center">
  <h1 align="center">Kakarot</h1>
  <h3 align="center">EVM interpreter written in Cairo.</h3>
</div>

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/abdelhamidbakhta/kakarot/TESTS?style=flat-square&logo=github)
![GitHub](https://img.shields.io/github/license/abdelhamidbakhta/kakarot?style=flat-square&logo=github)
![GitHub contributors](https://img.shields.io/github/contributors/abdelhamidbakhta/kakarot?logo=github&style=flat-square)
![Lines of code](https://img.shields.io/tokei/lines/github/abdelhamidbakhta/kakarot?style=flat-square)
![Discord](https://img.shields.io/discord/595666850260713488?color=purple&logo=discord&style=flat-square)
![GitHub Repo stars](https://img.shields.io/github/stars/abdelhamidbakhta/kakarot?style=social)

## ⚙️ Development

### 📦 Install the requirements

- [protostar](https://github.com/software-mansion/protostar)

### 🎉 Install

```bash
protostar install
```

### ⛏️ Compile

```bash
protostar build
```

### 🌡️ Test

```bash
# Run all tests
protostar test

# Run only unit tests
protostar test tests/units

# Run only integration tests
protostar test tests/integrations
```

### 🐛 Debug

Start the debug server:

```bash
python3 tests/debug/debug_server.py
# then use DEBUG env variable
# for example:
DEBUG=True protostar test
```

## 🚀 Deployment

```bash
# On testnet
./scripts/deploy_kakarot.sh -p testnet -a admin
```

With:

- `testnet` profile defined in protostar config file (testnet for alpha-goerli)
- `admin` alias to the admin account (optional if it is your `__default__` acount, see also starknet account [documentation](https://starknet.io/docs/hello_starknet/account_setup.html))

Contract addresses will be logged into the prompt.

### Inputs

To manage inputs sent to constructor during the deployment, you can customize the [config files](./scripts/configs/).

## 📄 License

**kakarot** is released under the [MIT](LICENSE).
