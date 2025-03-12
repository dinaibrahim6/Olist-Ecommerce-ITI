-- Prevent Orders with Zero Value:
create trigger prevent_order_zero_value on Order_Items After insert as
Begin
	if Exists(select 1 from inserted 
				join Order_Items on inserted.order_id = Order_Items.order_id
				group by Order_Items.order_id , inserted.price
				having inserted.price <=0 and Sum(Order_Items.price) < = 0)
	Begin
		Raiserror('Orders must have a positive value.',16,1)
		Rollback Transaction
	End
End



-- Prevent Custom Payment Values <= 10% of Order Value:
create trigger prevent_wrong_payment on Order_payments after insert as 
Begin 
	if Exists(select Order_Items.order_id, sum(price) as [Total Price]
			  from inserted join Orders
			  on inserted.order_id = Orders.order_id join Order_Items on Orders.order_id = Order_Items.order_id
			  group by Order_Items.order_id , inserted.payment_value
			  having inserted.payment_value <= 0.1 * sum(price) )
	Begin
		Raiserror('Payment must be at least 10% of the order value.',16,1)
		Rollback Transaction
	End
End


-- Enforce Review Creation After Order Completion:
create trigger Review_After_Delivery on Order_Reviews after insert as 
Begin 
	if Exists(select 1 
			  from inserted join Orders
			  on inserted.order_id = Orders.order_id
			  where order_delivered_customer_date is null)
	Begin
		Raiserror('Reviews can only be created after order delivery.',16,1)
		Rollback Transaction
	End
End



-- Track Late Deliveries:
create table Late_Delivery_Log (
    Order_Id int primary key,
    Delay_Days int,
    Logged_At datetime default getdate()
)

create trigger log_late_deliveries on Orders after update as 
Begin
	if Exists (select 1 from inserted where order_delivered_customer_date > order_estimated_delivery_date)
	Begin
		insert into Late_Delivery_Log (Order_Id, Delay_Days)
        select order_id, Datediff(day, order_estimated_delivery_date, order_delivered_customer_date)
        from inserted 
        where order_delivered_customer_date > order_estimated_delivery_date
	End
End 



-- Prevent Order Deletion
create trigger prevent_order_deletion on Orders instead of delete as
Begin
		Raiserror('Order deletion is not allowed.',16,1)
End



-- Prevent Over-Payment:
create trigger Prevent_Over_Payment on Order_Payments after insert as
Begin
	if Exists(Select 1 from inserted join (select order_id, sum(payment_value) as total_paid
											from Order_Payments
											group by order_id) P on inserted.order_id = P.order_id
											join 
											(select order_id, sum(price) as Order_value
											from Order_Items
											group by order_id
											)O on O.order_id = P.order_id
											where P.total_paid > O.Order_value)
		Begin
		Raiserror('Total payment cannot exceed the total order price.',16,1)
		Rollback Transaction
	End											
End

