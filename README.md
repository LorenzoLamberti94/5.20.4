# gap_sdk_private v5.20.4

## clone
```
git clone --recursive git@github.com:LorenzoLamberti94/5.20.4.git
```

## python env

```
conda create -n gap_sdk_5.20.4 python=3.10.16
conda activate gap_sdk_5.20.4
```

## Docker

Fast build (skips `make all` in image build):

```bash
docker build --platform=linux/amd64 -t gap9:5.20.4 .
```

This fast image already includes pre-seeded `fsbl/ssbl` binaries for standard GAP9 example runs.

Full SDK build inside image (slow):

```bash
docker build --platform=linux/amd64 --build-arg BUILD_SDK=1 -t gap9:5.20.4 .
```
