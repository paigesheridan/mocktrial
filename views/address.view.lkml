view: address {
  sql_table_name: sakila.address ;;
  drill_fields: [address_id]

  dimension: address_id {
    hidden: yes
    primary_key: yes
    type: number
    sql: ${TABLE}.address_id ;;
  }

  dimension: address {
    type: string
    sql: ${TABLE}.address ;;
  }

  dimension: address2 {
    type: string
    sql: ${TABLE}.address2 ;;
  }

  dimension: city_id {
    hidden: yes
    type: number
    sql: ${TABLE}.city_id ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}.district ;;
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

  dimension: phone {
    type: string
    sql: ${TABLE}.phone ;;
  }

  dimension: postal_code {
    map_layer_name: us_zipcode_tabulation_areas
    type: string
    sql: ${TABLE}.postal_code ;;
  }

  measure: count {
    type: count
    drill_fields: [address_id]
  }
}
