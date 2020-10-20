all::
	@echo "Enter a choice"
	@echo "Commands:"
	@echo ""
	@echo "./add.sh SERVER_NAME  - Will suspend and run the server you provide M-F 7pm-7am"
	@echo "make subscribe"
	@echo "make unsubscribe"
	@echo "make edit-hibernate-time"
	@echo "make edit-running-time"
	@echo "make clean"
	@echo "make list"

subscribe::
	oc apply -k subscribe/

unsubscribe::
	oc delete -k subscribe/

edit-hibernate-time::
	oc -n cluster-hibernation edit subscription.apps.open-cluster-management.io/cluster-hibernation-subscription

edit-running-time::
	oc -n cluster-hibernation edit subscription.apps.open-cluster-management.io/cluster-resumption

clean::
	rm Hibernating/*.yaml
	rm Running/*.yaml

list::
	echo $(MY_LIST)
	$(eval for cluster in `ls Hibernating`; do echo $${cluster/.yaml/}; done)
