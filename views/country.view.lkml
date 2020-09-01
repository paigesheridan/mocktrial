view: country {
  sql_table_name: sakila.country ;;
  drill_fields: [country_id]

  dimension: country_id {
    hidden: yes
    primary_key: yes
    type: number
    sql: ${TABLE}.country_id ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
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
    drill_fields: [country_id, city.count]
  }
}
