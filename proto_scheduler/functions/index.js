const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

// 'meeting-scheduler' Cloud Functions

const admin = require('firebase-admin')
admin.initializeApp()

const db = admin.firestore()

exports.updateSessionOptimalTime = functions.firestore.document("joined-sessions/{documentID}").onWrite((snap, context) => {
    const splitDoc = context.params.documentID.split("_")
    const sessionID = splitDoc[0]
    const userPhone = splitDoc[1]

    const currentUserDays = (snap.after.data())['days']
    
    var sessionUserWithDays = db.collection("joined-sessions").where("session_id", "==", sessionID).get().then((snapshot) => {

        // runs on error
        if(snapshot.size === 0){
            console.log("updateSessionOptimalTime(CF): Error with 'joined-sessions'")
        }

        

        var userWithDays = []
        snapshot.forEach((doc) => {
            if((doc.data())['phone_number'] === userPhone) return;
            userWithDays.push((doc.data())['days'])
        })
        // userWithDays.push(currentUserDays)
        console.log(`currentUserDays: ${currentUserDays}`)
        userWithDays.push(currentUserDays)
        return userWithDays
    })

    var daysToRanges = sessionUserWithDays.then((userWithDays) => {
        var mappedDays = []

        console.log(userWithDays.length)

        userWithDays.forEach((userDays) => {
            for(var i = 0; i < userDays.length; i++){
                
                var timesToRange = userDays[i]['times'].map((day) => {
                    return [day['min'], day['max']]
                })

                if(i >= mappedDays.length){
                    mappedDays.push([timesToRange])
                }else{
                    mappedDays[i].push(timesToRange)
                }
            }
        })

        return mappedDays
    })

    var optimalTime = daysToRanges.then((mappedDays) => {


        var maxTimesWithParticipants = []

        mappedDays.forEach((userForDate) => {

            var times_min = []
            var times_max = []

            userForDate.forEach((times) => {
                if(times.isEmpty){
                    return;
                }
                times.forEach((range) => {
                    times_min.push(range[0])
                    times_max.push(range[1])
                })
            })

            const maxTime = getDayMaxTime(times_min, times_max)
            console.log(maxTime)
            maxTimesWithParticipants.push(maxTime)
        })

        // FIXME: provide host with options from here-on

        // TODO: attach date with max range
        var maxParticipants = 0;
        
        var backupMaxTimes = Array.from(maxTimesWithParticipants)

        maxTimesWithParticipants.filter((val) => val !== null);

        maxTimesWithParticipants.sort((a, b) => {

            if(a === null || b === null){
                return false;
            }

            if(a.isEmpty || b.isEmpty){
                return false;
            }
            console.log("__look__")
            console.log(a)
            console.log(b)

            var maxOfTwo = -1;

            if(a[0] > b[0]){
                maxOfTwo = a[0]
            }else{
                maxOfTwo = b[0]
            }

            if(maxParticipants < maxOfTwo){
                maxParticipants = maxOfTwo
            }

            return (a[1][1] - a[1][0]) - (b[1][1] - b[1][0])
        })

        var optimalTime = maxTimesWithParticipants.pop();

        // FIXME: OPTIMAL TIME NOT WORKING

        while(optimalTime === undefined || optimalTime === null){
            console.log(optimalTime);
            if(optimalTime === null || optimalTime === undefined || optimalTime[0] !== maxParticipants){
                optimalTime = maxTimesWithParticipants.pop();
            }else{
                break;
            }
        }


        if(optimalTime !== null){
            const optimalTimeIndex = backupMaxTimes.findIndex((val) => {
                return val[0] === optimalTime[0] && val[1] === optimalTime[1]
            })
    
            console.log(`index: ${optimalTimeIndex}`)
    
            optimalTime.push(optimalTimeIndex)
    
    
            console.log(`optimal time: ${optimalTime[1]}`)
        }

       console.log(`Optmal: ${optimalTime}`)
        
        return optimalTime
    })

    optimalTime.then((optimalTime) => {
        if(optimalTime === null){
            throw Error;
        }

        return db.collection("session").doc(sessionID).update({
            "optimal_time": {
                "day_offset": optimalTime[2],
                "range": optimalTime[1],
                "participants": optimalTime[0]
            }
        }).catch((e) => console.log(e));
    }).catch((e) => console.log(e));

    functions.logger.log(`Hello: ${sessionID}`)
    // functions.logger.log(joinedSessions)
            
})

// TODO: Crank up the efficiency of this function "IT"S SLOW"
function getDayMaxTime(times_min, times_max){

        // Begin algo for maximized times
        var start = times_min
        var exit = times_max

        start.sort((a, b) => a - b)
        exit.sort((a, b) => a - b)


        var i = 1
        var j = 0
        const n = times_min.length + times_max.length

        var members_in = 1
        var max_members = 1
        var max_members_times = []
        var end_times = []
        var time = 0


        while(i < n && j < n){
            if(start[i] <= exit[j]){
                members_in += 1
                if(members_in === max_members){
                    max_members_times.push(start[i])
                }
                if(members_in > max_members){
                    max_members = members_in
                    time = start[i]
                    max_members_times = [time]
                    end_times = []
                }

                i += 1

                if(i === n && members_in === max_members){
                    end_times.push(exit[j])
                }
            }else{
                if(members_in === max_members){
                    end_times.push(exit[j])
                }
                members_in -= 1
                j += 1
            }
        }

        var retRanges = []

        var maxDifference = -1

        for(i = 0; i < max_members_times.length; i++){

            if(end_times[i] - max_members_times[i] > maxDifference){
                maxDifference = i
            }

            retRanges.push([max_members_times[i], end_times[i]])
        }
        // console.log("__look__")
        // console.log(retRanges);

        if(maxDifference === -1 || retRanges.isEmpty){
            return null
        }

        return [max_members, retRanges[maxDifference]]

        // console.log(`max_participants = ${max_members} at ${max_members_times}`)
        // console.log(`exit at ${end_times}`)
}

