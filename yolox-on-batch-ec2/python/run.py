
import os
from mmdetect_handler import collect_env, find_checkpoint, inference
from s3_handler import download_directory, download_file, upload_file

def main(input_bucket_name: str, input_object_key: str):

    bucket_name = os.getenv("BUCKET_NAME")
    input_prefix = os.getenv("OBJECT_INPUT_PREFIX")
    output_prefix = os.getenv("OBJECT_OUTPUT_PREFIX")
    print(f"{bucket_name=}")
    print(f"{input_prefix=}")
    print(f"{output_prefix=}")

    # 処理対象のオブジェクトを取得
    download_file("./input.jpg", input_bucket_name, input_object_key)

    # モデル等をダウンロード
    download_directory(destination_path="./checkpoints", bucket_name=bucket_name, prefix="asset/")

    # 環境ログを出力
    for name, val in collect_env().items():
        print(f"{name}: {val}")

    # モデルファイルを探索
    checkpoint_file = find_checkpoint(model_name="yolox_l_8x8_300e_coco", checkpoints_dir="./checkpoints")

    # 推論処理
    inference(checkpoint_file=str(checkpoint_file),
        model_name="yolox_l_8x8_300e_coco",
        device="cpu",
        input_image_file="./input.jpg",
        output_image_file="./output.jpg")

    # 結果をS3にupload
    output_object_key = output_prefix + input_object_key[len(input_prefix):]
    print(f"{output_object_key=}")
    upload_file("./output.jpg", bucket_name, output_object_key)

if __name__ == "__main__":

    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--input-bucket-name', required=True, type=str)
    parser.add_argument('--input-object-key', required=True, type=str)

    args = parser.parse_args()

    print(f"{args=}")

    main(**args.__dict__)
