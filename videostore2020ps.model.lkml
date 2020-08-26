connection: "video_store"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/view.lkml"                   # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
# explore: order_items {
#   join: orders {
#     relationship: many_to_one
#     sql_on: ${orders.id} = ${order_items.order_id} ;;
#   }
#
#   join: users {
#     relationship: many_to_one
#     sql_on: ${users.id} = ${orders.user_id} ;;
#   }
# }

explore: rental {
  join: payment {
    type: left_outer
    relationship: one_to_one
    sql_on: ${payment.rental_id} = ${rental.rental_id} ;;
  }

  join: customer {
    relationship: many_to_one
    sql_on: ${customer.customer_id}=${rental.customer_id} ;;
  }

  join: customer_facts {
    relationship: one_to_one
    sql_on: ${customer.customer_id} = ${customer_facts.customer_id} ;;
  }
}
