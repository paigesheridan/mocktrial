view: customer_facts {
  derived_table: {
    persist_for: "24 hours"
    indexes: ["customer_id"]
    sql: SELECT
        customer.customer_id  AS customer_id,
        min(rental.rental_date) AS first_rental_date,
        max(rental.rental_date) AS latest_rental_date,
        COUNT(*) AS rental_count,
        COALESCE(SUM(payment.amount ), 0) AS `payment.total_revenue`
      FROM sakila.rental  AS rental
      LEFT JOIN sakila.payment  AS payment ON payment.rental_id = rental.rental_id
      LEFT JOIN sakila.customer  AS customer ON customer.customer_id=rental.customer_id

      GROUP BY 1
      ORDER BY customer.customer_id
       ;;
  }

  dimension: customer_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.customer_id ;;
  }

  dimension_group: first_rental_date {
    type: time
    sql: ${TABLE}.first_rental_date ;;
  }

  dimension_group: latest_rental_date {
    type: time
    sql: ${TABLE}.latest_rental_date ;;
  }

  dimension: days_as_customer {
    type: number
    sql: DATEDIFF(${latest_rental_date_date}, ${first_rental_date_date}) ;;
  }

  dimension: days_as_customer_tier {
    type: tier
    tiers: [30,60,90,120,150,180,210,240]
    sql: ${days_as_customer} ;;
    style: integer
  }

  dimension: rental_count {
    label: "Number of Rentals"
    type: number
    sql: ${TABLE}.`rental.count` ;;
  }

  measure: total_rental_count {
    type: sum
    sql: ${rental_count} ;;
  }

  measure: average_rental_count {
    type: average
    sql: ${rental_count} ;;
    value_format_name: decimal_1
  }


  dimension: lifetime_value {
    label: "Lifetime Value by Customer"
    type: number
    sql: ${TABLE}.`payment.total_revenue` ;;
    value_format_name: usd
  }

  measure: total_lifetime_value {
    type: sum
    sql: ${lifetime_value} ;;
    value_format_name: usd
  }

  measure: avg_lifetime_value {
    type: average
    sql: ${lifetime_value} ;;
    value_format_name: usd
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [customer_id, first_rental_date_time, latest_rental_date_time, rental_count, lifetime_value]
  }
}
