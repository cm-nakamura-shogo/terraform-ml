from rich.pretty import pprint

def collect_env():
    import mmdet
    from mmengine.utils import get_git_hash
    from mmengine.utils.dl_utils import collect_env as collect_base_env

    """Collect the information of the running environments."""
    env_info = collect_base_env()
    env_info['MMDetection'] = f'{mmdet.__version__}+{get_git_hash()[:7]}'
    return env_info

def find_checkpoint(model_name: str,
                         checkpoints_dir: str="./checkpoints"):

    import pathlib
    checkpoints_path = pathlib.Path(checkpoints_dir)
    pattern = f"{model_name}_*.pth"
    checkpoints = sorted([ f for f in checkpoints_path.glob(pattern)])
    print(f"{checkpoints=}")
    if len(checkpoints) == 0:
        assert False, f"Cannot find checkpoint file: {checkpoints=}, {checkpoints_path=}, {pattern=}"

    checkpoint_file = checkpoints[0]

    print(f"{checkpoint_file=}")
    return checkpoint_file

def download_checkpoint(model_name: str,
                         checkpoints_dir: str="./checkpoints"):

    print(f"{model_name=}")
    print(f"{checkpoints_dir=}")

    import subprocess

    subprocess.run(["mkdir", "-p", checkpoints_dir])
    subprocess.run(["mim", "download", "mmdet", "--config", model_name, "--dest", checkpoints_dir])

    return find_checkpoint(model_name, checkpoints_dir)

def inference(model_name: str,
        checkpoint_file: str,
        input_image_file: str,
        output_image_file: str,
        device: str="cpu"):

    print(f"{model_name=}")
    print(f"{checkpoint_file=}")
    print(f"{input_image_file=}")
    print(f"{output_image_file=}")
    print(f"{device=}")

    # Set the device to be used for evaluation
    # device = 'cuda:0'
    device = 'cpu'

    # Initialize the DetInferencer
    from mmdet.apis import DetInferencer
    inferencer = DetInferencer(model_name, str(checkpoint_file), device)

    # Use the detector to do inference
    result = inferencer(input_image_file, no_save_vis=True, return_vis=True)
    pprint(result, max_length=4)

    from PIL import Image
    out_img = Image.fromarray(result["visualization"][0])
    out_img.save(output_image_file)

    return
