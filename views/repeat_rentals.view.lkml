view: repeat_rentals {
  derived_table: {
    sql: SELECT
        rental.customer_id,
        rental.rental_id,
        rental.rental_date,
        MIN(next.rental_date) as next_rental_date,
        MIN(next.rental_id) as next_rental_id,
        COUNT(DISTINCT next.rental_id) as number_of_subsequent_rentals,
        count(distinct rank.rental_date) as rank
      FROM rental rental
      LEFT JOIN rental next ON rental.customer_id=next.customer_id AND rental.rental_date < next.rental_date
      LEFT JOIN rental rank ON rental.customer_id=rank.customer_id AND rental.rental_date >= rank.rental_date
      GROUP BY 1,2,3
      order by 1,2 asc
      ;;

    indexes: ["customer_id"]
  }

  ###################### Native PDT Dimensions #####################

  dimension: customer_id {
    type: number
    sql: ${TABLE}.customer_id ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}.rental_id ;;
  }

  dimension_group: rental_date {
    type: time
    sql: ${TABLE}.rental_date ;;
  }

  dimension_group: next_rental_date {
    type: time
    sql: ${TABLE}.next_rental_date ;;
  }

  dimension: running_total_of_rentals {
    type: number
    sql: ${TABLE}.rank ;;
  }

  dimension: next_rental_id {
    type: number
    sql: ${TABLE}.next_rental_id ;;
  }

  dimension: number_of_subsequent_rentals {
    type: number
    sql: ${TABLE}.number_of_subsequent_rentals ;;
  }

  measure: count {
    type: count
    drill_fields: [customer_info*]
  }


###################### Derived Dimensions #####################


  dimension: days_until_next_rental {
    type: number
    sql: datediff(${next_rental_date_date},${rental_date_date}) ;;
  }


  dimension: days_until_next_rental_tier {
    type: tier
    sql: ${days_until_next_rental} ;;
    tiers: [30,60,90]
    style: integer
  }


###################### Derived Measures #####################


  measure: average_days_until_next_rental {
    type: average
    sql: ${days_until_next_rental} ;;
    value_format_name: decimal_1
  }

  measure: count_under_30_days {
    label: "Count with Subsequent Rental Less than 30 Days Later"
    type: count
    filters: {
      field: days_until_next_rental_tier
      value: "Below 30"
    }
  }

  measure: percent_rerenting_within_30 {
    label: "Percentage with Repeat Rentals within 30 Days"
    type: number
    sql: 1.0*${count_under_30_days}/nullif(${count},0) ;;
    value_format_name: percent_1
  }

  measure: count_30_to_60_days {
    label: "Count with Subsequent Rental 30-60 Days Later"
    type: count
    filters: {
      field: days_until_next_rental_tier
      value: "30 to 59"
    }
  }

  measure: percent_rerenting_within_30_60 {
    label: "Percentage with Repeat Rentals within 30-60 Days"
    type: number
    sql: 1.0*${count_30_to_60_days}/nullif(${count},0) ;;
    value_format_name: percent_1
  }

  measure: count_60_to_90_days {
    label: "Count with Subsequent Rental 60-90 Days Later"
    type: count
    filters: {
      field: days_until_next_rental_tier
      value: "60 to 89"
    }
  }

  measure: percent_rerenting_within_60_90 {
    label: "Percentage with Repeat Rental within 60-90 Days"
    type: number
    sql: 1.0*${count_60_to_90_days}/nullif(${count},0) ;;
    value_format_name: percent_1
  }

  measure: count_90_and_above {
    label: "Count with Subsequent Rental 90+ Days Later"
    type: count
    filters: {
      field: days_until_next_rental_tier
      value: "90 or Above"
    }
  }

  measure: percent_rerenting_within_90_and_above {
    label: "Percentage with Repeat Rental after 90 or More Days"
    type: number
    sql: 1.0*${count_90_and_above}/nullif(${count},0) ;;
    value_format_name: percent_1
  }

  measure: count_no_subsequent_rentals {
    label: "Count with No Subsequent Rentals"
    type: count
    filters: {
      field: number_of_subsequent_rentals
      value: "0"
    }
  }

  measure: percent_with_no_repeat_rentals {
    label: "Percentage with no Repeat Rentals"
    type: number
    sql: 1.0*${count_no_subsequent_rentals}/nullif(${count},0) ;;
    value_format_name: percent_1
  }

  measure: avg_total_rentals {
    label: "Average Running Count of Rentals"
    type: average
    sql: ${running_total_of_rentals} ;;
    value_format_name: decimal_1
  }

  measure: average_rentals_to_reach_100_LTV {
    label: "Average Rentals to Reach 100 Dollars in Lifetime Value"
    type: average
    sql: ${running_total_of_rentals} ;;
    filters: {
      field: customer_lifetime_value.crosses_100_LTV_threshold
      value: "Yes"
    }
    drill_fields: [customer_id, rental.rental_date, film.title, film.category, payment.amount, customer_lifetime_value.user_rental_running_total]
    value_format_name: decimal_1
  }

  measure: average_number_of_subsequent_rentals {
    type: average
    sql: ${number_of_subsequent_rentals} ;;
    value_format_name: decimal_1
  }


###################### Sets #####################


  set: detail {
    fields: [
      customer_id,
      rental_id,
      rental_date_time,
      next_rental_date_time,
      next_rental_id,
      number_of_subsequent_rentals
    ]
  }

  set: customer_info {
    fields: [
      customer_id,
      customer.full_name,
      customer.email,
      customer_facts.first_rental_date,
      customer_facts.days_as_customer,
      customer_facts.lifetime_value
    ]
  }
}
