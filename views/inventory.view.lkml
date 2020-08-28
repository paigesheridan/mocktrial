view: inventory {
  sql_table_name: sakila.inventory ;;
  drill_fields: [inventory_id]

  dimension: inventory_id {
    hidden: yes
    primary_key: yes
    type: number
    sql: ${TABLE}.inventory_id ;;
  }

  dimension: film_id {
    hidden: yes
    type: number
    sql: ${TABLE}.film_id ;;
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

  dimension: store_id {
    hidden: yes
    type: yesno
    sql: ${TABLE}.store_id ;;
  }

  measure: count {
    hidden: yes
    type: count
    drill_fields: [inventory_id]
  }
}
