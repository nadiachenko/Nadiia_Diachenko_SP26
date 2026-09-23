import allure
import requests


@allure.title("User 3 has exactly 10 posts")
def test_user_3_post_count(base_url):
    with allure.step("Request posts for user 3"):
        response = requests.get(f"{base_url}/posts", params={"userId": 3})

    with allure.step("Verify the request succeeded"):
        assert response.status_code == 200, \
            f"Expected 200, got {response.status_code}"

    with allure.step("Verify 10 posts were returned"):
        posts = response.json()
        assert len(posts) == 10, f"Expected 10 posts, got {len(posts)}"


@allure.title("Source (GCP) and target (AWS) buckets are not empty for the date")
def test_buckets_not_empty(gcp_client, gcp_bucket, gcp_date_prefix,
                           s3_client, target_bucket, date_prefix):
    with allure.step("Verify GCP source bucket has data for the date"):
        blobs = list(
            gcp_client.list_blobs(gcp_bucket, prefix=gcp_date_prefix, max_results=1)
        )
        assert len(blobs) > 0, \
            f"GCP bucket {gcp_bucket} has no objects under {gcp_date_prefix}"

    with allure.step("Verify AWS target staging bucket has data for the date"):
        response = s3_client.list_objects_v2(
            Bucket=target_bucket, Prefix=date_prefix, MaxKeys=1
        )
        assert response.get("KeyCount", 0) > 0, \
            f"AWS bucket {target_bucket} has no objects under {date_prefix}"
