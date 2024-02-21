{{ config(materialized = 'incremental') }}

with extracted_date as (
    select
        hourly_avg,
        extract(year from date) as year,
        extract(month from date) as month
    from {{ ref("stg_bigquery_hourly_production") }}
    {% if is_incremental() %}
        where
            extract(month from date)
            > (
                select max(month)
                from {{ this }}
                where year = extract(year from date)
            )
    {% endif %}
),

monthly_avg as (
    select
        year,
        month,
        sum(hourly_avg) as production_kwh
    from extracted_date
    group by year, month
)

select
    monthly_avg.year,
    monthly_avg.month,
    monthly_avg.production_kwh,
    tarif_annuel.prix_kwh * monthly_avg.production_kwh
    + tarif_annuel.bonus_kwh * monthly_avg.production_kwh as revenue
from monthly_avg
inner join
    {{ source('raw_bigquery', 'tarif_annuel') }} as tarif_annuel
    on monthly_avg.year = tarif_annuel.year
order by
    monthly_avg.year desc,
    monthly_avg.month desc
