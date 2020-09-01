view: city {
  sql_table_name: sakila.city ;;
  drill_fields: [city_id]

  dimension: city_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.city_id ;;
  }

  dimension: city {
    #map_layer_name:
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: country_id {
    type: number
    hidden: yes
    sql: ${TABLE}.country_id ;;
  }

  dimension_group: last_update {
    hidden: yes
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.last_update ;;
  }

  measure: count {
    hidden: yes
    type: count
    drill_fields: [city_id, country.country_id]
  }
}
