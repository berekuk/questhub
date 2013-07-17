define ["models/current-user"], (currentUser) ->
    describe "model/current-user", ->
        describe "spec.js mocks", ->
            it "registered", ->
                expect(currentUser.get("registered")).toEqual 1


        describe "touring:", ->
            it "not on tour initially", ->
                expect(currentUser.onTour("realms")).not.toBe true

            it "on tour after starting a tour", ->
                expect(currentUser.onTour("realms")).not.toBe true
                currentUser.startTour()
                expect(currentUser.onTour("realms")).toBe true

            it "onTour returns truth only once", ->
                expect(currentUser.onTour("realms")).not.toBe true
                currentUser.startTour()
                expect(currentUser.onTour("realms")).toBe true
                expect(currentUser.onTour("realms")).not.toBe true
                expect(currentUser.onTour("realms")).not.toBe true
                expect(currentUser.onTour("profile")).toBe true
                expect(currentUser.onTour("profile")).not.toBe true


        describe "settings:", ->
            server = undefined
            beforeEach ->
                sinon.spy mixpanel, "track"
                server = sinon.fakeServer.create()
                currentUser.set "settings", {}

            afterEach ->
                mixpanel.track.restore()
                server.restore()

            describe "getSetting", ->
                it "on unknown setting", ->
                    expect(currentUser.getSetting("blah")).toBe `undefined`

                it "on known setting", ->
                    currentUser.set "settings",
                        foo: 5
                        bar: 6

                    expect(currentUser.getSetting("foo")).toEqual 5

            it "setSetting", ->
                currentUser.setSetting "foo", 7
                expect(currentUser.getSetting("foo")).toEqual 7


        describe "registration:", ->
            it "needsToRegister", ->
                expect(currentUser.needsToRegister()).not.toBe true


        describe "following", ->
            server = undefined
            beforeEach ->
                sinon.spy mixpanel, "track"
                server = sinon.fakeServer.create()

            afterEach ->
                mixpanel.track.restore()
                server.restore()

            describe "realms:", ->
                beforeEach ->
                    server.respondWith "POST", "/api/follow_realm/blah", [200,
                        "Content-Type": "application/json"
                    , JSON.stringify(result: "ok")]
                    server.respondWith "POST", "/api/unfollow_realm/blah", [200,
                        "Content-Type": "application/json"
                    , JSON.stringify(result: "ok")]

                _.each ["follow", "unfollow"], (t) ->
                    method = t + "Realm"
                    describe method, ->
                        it "calls mixpanel.track", ->
                            currentUser[method] "blah"
                            server.respond()
                            expect(mixpanel.track.calledOnce).toBe true
                            expect(mixpanel.track.calledWith(t + " realm")).toBe true

                        it "posts to API", ->
                            currentUser[method] "blah"
                            server.respond()
                            expect(server.requests.length).toEqual 2 # follow, and then refetch self
                            expect(server.requests[0].method).toEqual "POST"
                            expect(server.requests[0].url).toEqual "/api/" + t + "_realm/blah"

            describe "players:", ->
                beforeEach ->
                    server.respondWith "POST", "/api/user/somebody/follow", [200,
                        "Content-Type": "application/json"
                    , JSON.stringify(result: "ok")]
                    server.respondWith "POST", "/api/user/somebody/unfollow", [200,
                        "Content-Type": "application/json"
                    , JSON.stringify(result: "ok")]

                _.each ["follow", "unfollow"], (t) ->
                    method = t + "User"
                    describe method, ->
                        it "calls mixpanel.track", ->
                            currentUser[method] "somebody"
                            server.respond()
                            expect(mixpanel.track.calledOnce).toBe true
                            expect(mixpanel.track.calledWith(t + " user")).toBe true

                        it "posts to API", ->
                            currentUser[method] "somebody"
                            server.respond()
                            expect(server.requests.length).toEqual 2 # follow, and then refetch self
                            expect(server.requests[0].method).toEqual "POST"
                            expect(server.requests[0].url).toEqual "/api/user/somebody/" + t
