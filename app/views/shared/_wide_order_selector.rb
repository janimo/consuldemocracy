<% # Params:
   #
   #   i18n_namespace: for example "moderation.debates.index"
%>

<form class="inline-block">
  <label for="order-selector-participation" class="sr-only"><%= t("debates.index.select_order") %></label>
  <select class="js-location-changer js-order-selector select-order" data-order="<%= @current_order %>" name="order-selector" id="order-selector-participation">
     <% @valid_orders.each do |order| %>
       <option <%= 'selected' if order == @current_order %>
               value='<%= current_path_with_query_params(order: order, page: 1) %>'>
         <%= t("#{i18n_namespace}.orders.#{order}") %>
       </option>
     <% end %>
   </select>
</form>
