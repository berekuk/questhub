define([
    'models/current-user'
], function (currentUser) {
    describe('model/current-user', function () {
        describe('spec.js mocks', function () {
            it('registered', function () {
                expect(currentUser.get('registered')).toEqual(1);
            });
        });

        describe('touring:', function () {
            it('not on tour initially', function () {
                expect(currentUser.onTour('realms')).not.toBe(true);
            });

            it('on tour after starting a tour', function () {
                expect(currentUser.onTour('realms')).not.toBe(true);
                currentUser.startTour();
                expect(currentUser.onTour('realms')).toBe(true);
            });

            it('onTour returns truth only once', function () {
                expect(currentUser.onTour('realms')).not.toBe(true);

                currentUser.startTour();

                expect(currentUser.onTour('realms')).toBe(true);
                expect(currentUser.onTour('realms')).not.toBe(true);
                expect(currentUser.onTour('realms')).not.toBe(true);

                expect(currentUser.onTour('profile')).toBe(true);
                expect(currentUser.onTour('profile')).not.toBe(true);
            });
        });

        describe('settings:', function () {
            beforeEach(function () {
                currentUser.set('settings', {});
            });

            describe('getSetting', function () {
                it('on unknown setting', function () {
                    expect(currentUser.getSetting('blah')).toBe(undefined);
                });
                it('on known setting', function () {
                    currentUser.set('settings', { foo: 5, bar: 6 });
                    expect(currentUser.getSetting('foo')).toEqual(5);
                });
            });

            it('setSetting', function () {
                currentUser.setSetting('foo', 7);
                expect(currentUser.getSetting('foo')).toEqual(7);
            });
        });

        describe('registration:', function () {
            it('needsToRegister', function () {
                expect(currentUser.needsToRegister()).not.toBe(true);
            });
        });
    });
});
