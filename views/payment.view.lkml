view: payment {
  sql_table_name: sakila.payment ;;
  drill_fields: [payment_id]

  dimension: payment_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.payment_id ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}.amount ;;
  }

  measure: total_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
  }

  measure: average_rental_amount {
    type: average
    sql: ${amount} ;;
    value_format_name: usd
  }

  dimension: customer_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.customer_id ;;
  }

  dimension_group: last_update {
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

  dimension_group: payment {
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
    sql: ${TABLE}.payment_date ;;
  }

  dimension: rental_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.rental_id ;;
  }

  dimension: staff_id {
    type: yesno
    sql: ${TABLE}.staff_id ;;
  }

  dimension: user_rental_running_total {
    label: "Lifetime Value Running Total by Rental"
    type: number
    value_format_name: usd
    sql: (
          SELECT SUM(amount)
          FROM payment p
          WHERE p.payment_date <= ${TABLE}.payment_date
          AND p.customer_id = ${TABLE}.customer_id
          ) ;;
  }

  dimension: previous_user_rental_running_total {
    hidden: yes
    type: number
    value_format_name: usd
    sql: (
          SELECT SUM(amount)
          FROM payment p
          WHERE p.payment_date < ${TABLE}.payment_date
          AND p.customer_id = ${TABLE}.customer_id
          ) ;;
  }

  dimension: crosses_100_LTV_threshold {
    hidden: yes
    type: yesno
    sql: ${previous_user_rental_running_total} <100 and ${user_rental_running_total} >=100  ;;
  }


  dimension: crosses_150_LTV_threshold {
    type: yesno
    hidden: yes
    sql: ${previous_user_rental_running_total} <150 and ${user_rental_running_total} >=150  ;;
  }

  dimension: crosses_200_LTV_threshold {
    type: yesno
    hidden: yes
    sql: ${previous_user_rental_running_total} <200 and ${user_rental_running_total} >=200  ;;
  }

  dimension: crosses_250_LTV_threshold {
    type: yesno
    hidden: yes
    sql: ${previous_user_rental_running_total} <250 and ${user_rental_running_total} >=250  ;;
  }


  measure: count {
    type: count
    drill_fields: [payment_id, rental.rental_id, customer.first_name, customer.last_name, customer.customer_id]
  }
}
