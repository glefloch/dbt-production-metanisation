{{ config(materialized = 'incremental') }}

with five_min_avg as (
    select
        timestamp_field_0 as date,
        (
            int64_field_1
            + int64_field_2
            + int64_field_3
            + int64_field_4
            + int64_field_5
            + int64_field_6
            + int64_field_7
            + int64_field_8
            + int64_field_9
            + int64_field_10
            + int64_field_11
            + int64_field_12
        )
        / 12 as hourly_avg
    from {{ source('raw_bigquery', 'csv-5min') }}
    {% if is_incremental() %}
        where timestamp_field_0 > (select max(date) from {{ this }})
    {% endif %}
),

ten_min_avg as (
    select
        timestamp_field_0 as date,
        (
            int64_field_1
            + int64_field_2
            + int64_field_3
            + int64_field_4
            + int64_field_5
            + int64_field_6
        )
        / 6 as hourly_avg
    from {{ source('raw_bigquery', 'csv-data') }}
    {% if is_incremental() %}
        where timestamp_field_0 > (select max(date) from {{ this }})
    {% endif %}
)

select *
from five_min_avg
union all
select * from ten_min_avg
