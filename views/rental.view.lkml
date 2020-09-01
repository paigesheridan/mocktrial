view: rental {
  sql_table_name: sakila.rental ;;
  drill_fields: [rental_id]


###################### Native Dimensions #####################

  dimension: rental_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.rental_id ;;
  }

  dimension: customer_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.customer_id ;;
  }

  dimension: inventory_id {
    type: number
    sql: ${TABLE}.inventory_id ;;
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

  dimension_group: rental {
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
    sql: ${TABLE}.rental_date ;;
  }


  dimension_group: return {
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
    sql: ${TABLE}.return_date ;;
  }

  dimension: staff_id {
    type: yesno
    sql: ${TABLE}.staff_id ;;
  }


###################### Derived Dimensions #####################


  dimension: days_as_customer {
    type: number
    sql: datediff(${rental_date},${customer_facts.first_rental_date_date}) ;;
  }

  dimension: due_date {
    type: date
    sql: DATE_ADD(${rental_date}, INTERVAL 8 DAY) ;;
  }

  dimension: is_late {
    type: yesno
    sql: ${return_date} > ${due_date} OR (${return_date} is null and ${due_date}>'2006-02-21') ;;
  }

  dimension: number_of_days_late {
    type: number
    sql: CASE WHEN ${is_late} = "No" THEN 0
      ELSE datediff(${return_date},${due_date}) END ;;
  }


###################### Derived Measures #####################


  measure: average_days_to_reach_100_LTV {
    label: "Average Days to Reach 100 Dollars in Lifetime Value"
    type: average
    sql: ${days_as_customer} ;;
    filters: {
      field: customer_lifetime_value.crosses_100_LTV_threshold
      value: "Yes"
    }
    value_format_name: decimal_1
    drill_fields: [customer_id, rental_date, film.title, film.category, payment.amount, customer_lifetime_value.user_rental_running_total]

  }

  measure: average_days_to_reach_150_LTV {
    label: "Average Days to Reach 150 Dollars in Lifetime Value"
    type: average
    sql: ${days_as_customer} ;;
    filters: {
      field: customer_lifetime_value.crosses_150_LTV_threshold
      value: "Yes"
    }
    value_format_name: decimal_1
    drill_fields: [customer_id, rental_date, film.title, film.category, payment.amount, customer_lifetime_value.user_rental_running_total]

  }

  measure: average_days_to_reach_200_LTV {
    label: "Average Days to Reach 200 Dollars in Lifetime Value"
    type: average
    sql: ${days_as_customer} ;;
    filters: {
      field: customer_lifetime_value.crosses_200_LTV_threshold
      value: "Yes"
    }
    value_format_name: decimal_1
    drill_fields: [customer_id, rental_date, film.title, film.category, payment.amount, customer_lifetime_value.user_rental_running_total]

  }

  measure: average_days_to_reach_250_LTV {
    label: "Average Days to Reach 250 Dollars in Lifetime Value"
    type: average
    sql: ${days_as_customer} ;;
    filters: {
      field: customer_lifetime_value.crosses_250_LTV_threshold
      value: "Yes"
    }
    value_format_name: decimal_1
    drill_fields: [customer_id, rental_date, film.title, film.category, payment.amount, customer_lifetime_value.user_rental_running_total]
  }

  measure: average_days_late {
    type: average
    sql: ${number_of_days_late} ;;
    value_format_name: decimal_1
  }

  measure: number_of_late_rentals {
    type: count
    filters: {
      field: is_late
      value: "Yes"
    }
  }

  measure: pct_late_rentals {
    label: "Percent Rentals Returned Late"
    type: number
    sql: 1.0*${number_of_late_rentals}/ nullif(${count},0) ;;
    value_format_name: percent_1
    drill_fields: [rental_id, rental_date, film.title, payment.amount]
  }


  measure: count {
    label: "Count of Rentals"
    type: count
    drill_fields: [rental_id, rental_date, customer.full_name, customer.email, film.title, payment.amount, number_of_days_late]
  }
}
