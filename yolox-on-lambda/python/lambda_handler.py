
import os
from mmdetect_handler import collect_env, find_checkpoint, inference
from s3_handler import download_directory, download_file, upload_file

def handler(event: dict, context):

    print(f"{event=}")
    print(f"{context=}")

    bucket_name = os.getenv("BUCKET_NAME")
    input_prefix = os.getenv("OBJECT_INPUT_PREFIX")
    output_prefix = os.getenv("OBJECT_OUTPUT_PREFIX")
    print(f"{bucket_name=}")
    print(f"{input_prefix=}")
    print(f"{output_prefix=}")

    # 処理対象のオブジェクトキーを取得
    target_object_key = event['Records'][0]['s3']['object']['key']

    # 処理対象のオブジェクトを取得
    download_file("/tmp/input.jpg", bucket_name, target_object_key)

    # モデル等をダウンロード
    download_directory(destination_path="/tmp/asset", bucket_name=bucket_name, prefix="asset/")

    # 環境ログを出力
    for name, val in collect_env().items():
        print(f"{name}: {val}")

    # モデルファイルを探索
    checkpoint_file = find_checkpoint(model_name="yolox_l_8x8_300e_coco", checkpoints_dir="/tmp/asset")

    # 推論処理
    inference(checkpoint_file=str(checkpoint_file),
        model_name="yolox_l_8x8_300e_coco",
        device="cpu",
        input_image_file="/tmp/input.jpg",
        output_image_file="/tmp/output.jpg")

    # 結果をS3にupload
    output_object_key = output_prefix + target_object_key[len(input_prefix):]
    print(f"{output_object_key=}")
    upload_file("/tmp/output.jpg", bucket_name, output_object_key)

    return {
        "statusCode": 200,
        "body": "OK"
    }
