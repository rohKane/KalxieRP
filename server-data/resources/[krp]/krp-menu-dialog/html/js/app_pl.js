(function () {

	let MenuTpl =
		'<div id="menu_{{_namespace}}_{{_name}}" class="dialog {{#isBig}}big{{/isBig}}">' +
			'<div class="head"><span>{{title}}</span></div>' +
				'{{#isDefault}}<input type="text" name="value" id="inputText"/>{{/isDefault}}' +
				'{{#isBig}}<textarea name="value"/>{{/isBig}}' +
				'<button type="button" name="submit">Zapisz</button>' +
				'<button type="button" name="cancel">Zamknij</button>' +
			'</div>' +
		'</div>'
	;

	window.KRPCore_MENU       = {};
	KRPCore_MENU.ResourceName = 'krp-menu-dialog';
	KRPCore_MENU.opened       = {};
	KRPCore_MENU.focus        = [];
	KRPCore_MENU.pos          = {};

	KRPCore_MENU.open = function (namespace, name, data) {

		if (typeof KRPCore_MENU.opened[namespace] == 'undefined') {
			KRPCore_MENU.opened[namespace] = {};
		}

		if (typeof KRPCore_MENU.opened[namespace][name] != 'undefined') {
			KRPCore_MENU.close(namespace, name);
		}

		if (typeof KRPCore_MENU.pos[namespace] == 'undefined') {
			KRPCore_MENU.pos[namespace] = {};
		}

		if (typeof data.type == 'undefined') {
			data.type = 'default';
		}

		if (typeof data.align == 'undefined') {
			data.align = 'top-left';
		}

		data._index = KRPCore_MENU.focus.length;
		data._namespace = namespace;
		data._name = name;

		KRPCore_MENU.opened[namespace][name] = data;
		KRPCore_MENU.pos[namespace][name] = 0;

		KRPCore_MENU.focus.push({
			namespace: namespace,
			name: name
		});

		document.onkeyup = function (key) {
			if (key.which == 27) { // Escape key
				$.post('http://' + KRPCore_MENU.ResourceName + '/menu_cancel', JSON.stringify(data));
			} else if (key.which == 13) { // Enter key
				$.post('http://' + KRPCore_MENU.ResourceName + '/menu_submit', JSON.stringify(data));
			}
		};

		KRPCore_MENU.render();

	};

	KRPCore_MENU.close = function (namespace, name) {

		delete KRPCore_MENU.opened[namespace][name];

		for (let i = 0; i < KRPCore_MENU.focus.length; i++) {
			if (KRPCore_MENU.focus[i].namespace == namespace && KRPCore_MENU.focus[i].name == name) {
				KRPCore_MENU.focus.splice(i, 1);
				break;
			}
		}

		KRPCore_MENU.render();

	};

	KRPCore_MENU.render = function () {

		let menuContainer = $('#menus')[0];

		$(menuContainer).find('button[name="submit"]').unbind('click');
		$(menuContainer).find('button[name="cancel"]').unbind('click');
		$(menuContainer).find('[name="value"]').unbind('input propertychange');

		menuContainer.innerHTML = '';

		$(menuContainer).hide();

		for (let namespace in KRPCore_MENU.opened) {
			for (let name in KRPCore_MENU.opened[namespace]) {

				let menuData = KRPCore_MENU.opened[namespace][name];
				let view = JSON.parse(JSON.stringify(menuData));

				switch (menuData.type) {
					case 'default': {
						view.isDefault = true;
						break;
					}

					case 'big': {
						view.isBig = true;
						break;
					}

					default: break;
				}

				let menu = $(Mustache.render(MenuTpl, view))[0];

				$(menu).css('z-index', 1000 + view._index);

				$(menu).find('button[name="submit"]').click(function () {
					KRPCore_MENU.submit(this.namespace, this.name, this.data);
				}.bind({ namespace: namespace, name: name, data: menuData }));

				$(menu).find('button[name="cancel"]').click(function () {
					KRPCore_MENU.cancel(this.namespace, this.name, this.data);
				}.bind({ namespace: namespace, name: name, data: menuData }));

				$(menu).find('[name="value"]').bind('input propertychange', function () {
					this.data.value = $(menu).find('[name="value"]').val();
					KRPCore_MENU.change(this.namespace, this.name, this.data);
				}.bind({ namespace: namespace, name: name, data: menuData }));

				if (typeof menuData.value != 'undefined')
					$(menu).find('[name="value"]').val(menuData.value);

				menuContainer.appendChild(menu);
			}
		}

		$(menuContainer).show();
		$("#inputText").focus();
	};

	KRPCore_MENU.submit = function (namespace, name, data) {
		$.post('http://' + KRPCore_MENU.ResourceName + '/menu_submit', JSON.stringify(data));
	};

	KRPCore_MENU.cancel = function (namespace, name, data) {
		$.post('http://' + KRPCore_MENU.ResourceName + '/menu_cancel', JSON.stringify(data));
	};

	KRPCore_MENU.change = function (namespace, name, data) {
		$.post('http://' + KRPCore_MENU.ResourceName + '/menu_change', JSON.stringify(data));
	};

	KRPCore_MENU.getFocused = function () {
		return KRPCore_MENU.focus[KRPCore_MENU.focus.length - 1];
	};

	window.onData = (data) => {

		switch (data.action) {
			case 'openMenu': {
				KRPCore_MENU.open(data.namespace, data.name, data.data);
				break;
			}

			case 'closeMenu': {
				KRPCore_MENU.close(data.namespace, data.name);
				break;
			}
		}

	};

	window.onload = function (e) {
		window.addEventListener('message', (event) => {
			onData(event.data);
		});
	};

})();