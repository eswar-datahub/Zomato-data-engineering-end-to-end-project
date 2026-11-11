select 
    f_id,
    item as food_name,
    initcap(veg_or_non_veg) as food_type,
    from {{ source('raw', 'food') }} where try_to_number(f_id) is not null
    