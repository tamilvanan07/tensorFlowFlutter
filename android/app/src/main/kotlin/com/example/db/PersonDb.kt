package com.example.db

import io.objectbox.kotlin.flow
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flowOn

class PersonDB {

    private val personBox = ObjectBoxStore.store.boxFor(PersonRecord::class.java)

    fun addPerson(person: PersonRecord): Long {
        return personBox.put(person)
    }

    fun removePerson(personID: Long) {
        return personBox.removeByIds(listOf(personID))
    }

    fun removePersonFromList(person: PersonRecord): Boolean {
        return personBox.remove(person)
    }

    fun searchExistingPerson(personName: String): Boolean {
        return personBox.query(PersonRecord_.personName.equal(personName)).build().findFirst() != null
    }


    // Returns the number of records present in the collection
    fun getCount(): Long = personBox.count()

    @OptIn(ExperimentalCoroutinesApi::class)
    fun getAll(): Flow<MutableList<PersonRecord>> =
        personBox.query(PersonRecord_.personID.notNull()).build().flow().flowOn(Dispatchers.IO)


    fun getPersonById(personID: Long): PersonRecord? {
        return personBox.query(PersonRecord_.personID.equal(personID)).build().findFirst()
    }

    fun updatePerson(person: PersonRecord) {
        personBox.put(person)
    }

    fun removeAll() {
        personBox.removeAll()
    }

    fun getPersonByName(name: String): PersonRecord? {
        return personBox.query(PersonRecord_.personName.equal(name)).build().findFirst()
    }

    fun removePersonByName(name: String) {
        val person = getPersonByName(name)
        if (person != null) {
            removePerson(person.personID)
        }
    }

    fun getPersonCountByName(name: String): Long {
        return personBox.query(PersonRecord_.personName.equal(name)).build().count()
    }



}