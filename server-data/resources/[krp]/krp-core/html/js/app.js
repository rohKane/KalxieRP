(() => {

	KRPCore = {};
	KRPCore.HUDElements = [];

	KRPCore.setHUDDisplay = function (opacity) {
		$('#hud').css('opacity', opacity);
	};

	KRPCore.insertHUDElement = function (name, index, priority, html, data) {
		KRPCore.HUDElements.push({
			name: name,
			index: index,
			priority: priority,
			html: html,
			data: data
		});

		KRPCore.HUDElements.sort((a, b) => {
			return a.index - b.index || b.priority - a.priority;
		});
	};

	KRPCore.updateHUDElement = function (name, data) {

		for (let i = 0; i < KRPCore.HUDElements.length; i++) {
			if (KRPCore.HUDElements[i].name == name) {
				KRPCore.HUDElements[i].data = data;
			}
		}

		KRPCore.refreshHUD();
	};

	KRPCore.deleteHUDElement = function (name) {
		for (let i = 0; i < KRPCore.HUDElements.length; i++) {
			if (KRPCore.HUDElements[i].name == name) {
				KRPCore.HUDElements.splice(i, 1);
			}
		}

		KRPCore.refreshHUD();
	};

	KRPCore.refreshHUD = function () {
		$('#hud').html('');

		for (let i = 0; i < KRPCore.HUDElements.length; i++) {
			let html = Mustache.render(KRPCore.HUDElements[i].html, KRPCore.HUDElements[i].data);
			$('#hud').append(html);
		}
	};

	KRPCore.inventoryNotification = function (add, item, count) {
		let notif = '';

		if (add) {
			notif += '+';
		} else {
			notif += '-';
		}

		notif += count + ' ' + item.label;

		let elem = $('<div>' + notif + '</div>');

		$('#inventory_notifications').append(elem);

		$(elem).delay(3000).fadeOut(1000, function () {
			elem.remove();
		});
	};

	window.onData = (data) => {
		switch (data.action) {
			case 'setHUDDisplay': {
				KRPCore.setHUDDisplay(data.opacity);
				break;
			}

			case 'insertHUDElement': {
				KRPCore.insertHUDElement(data.name, data.index, data.priority, data.html, data.data);
				break;
			}

			case 'updateHUDElement': {
				KRPCore.updateHUDElement(data.name, data.data);
				break;
			}

			case 'deleteHUDElement': {
				KRPCore.deleteHUDElement(data.name);
				break;
			}

			case 'inventoryNotification': {
				KRPCore.inventoryNotification(data.add, data.item, data.count);
			}
		}
	};

	window.onload = function (e) {
		window.addEventListener('message', (event) => {
			onData(event.data);
		});
	};

})();