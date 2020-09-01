view: customer_lifetime_value {
  derived_table: {
    sql: SELECT
        payment.customer_id,
        payment.rental_id,
        (
                SELECT SUM(amount)
                FROM payment p
                WHERE p.payment_date < payment.payment_date
                AND p.customer_id = payment.customer_id
                )  AS previous_user_rental_running_total,
        (
                SELECT SUM(amount)
                FROM payment p
                WHERE p.payment_date <= payment.payment_date
                AND p.customer_id = payment.customer_id
                )  AS user_rental_running_total
      FROM sakila.rental  AS rental
      LEFT JOIN sakila.payment  AS payment ON payment.rental_id = rental.rental_id

      GROUP BY 1,2
      ORDER BY payment.customer_id
       ;;
  indexes: ["rental_id"]

  persist_for: "24 hours"
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: customer_id {
    type: number
    sql: ${TABLE}.customer_id ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}.rental_id ;;
  }

  dimension: previous_user_rental_running_total {
    type: number
    sql: ${TABLE}.previous_user_rental_running_total ;;
    value_format_name: usd
  }

  dimension: user_rental_running_total {
    type: number
    sql: ${TABLE}.user_rental_running_total ;;
    value_format_name: usd
  }

################ Derived Dimensions & Measures ################

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

  measure: total_running_total_over_time {
    label: "Running Total Over Time"
    type: sum
    sql: ${user_rental_running_total} ;;
    value_format_name: usd
  }


  set: detail {
    fields: [customer_id, rental_id, previous_user_rental_running_total, user_rental_running_total]
  }
}
