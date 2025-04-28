package com.example.tensor_flow_project

import kotlinx.coroutines.flow.Flow
import com.example.db.PersonDB
import com.example.db.PersonRecord



class PersonUseCase(private val personDB: PersonDB) {

    fun addPerson(name: String, numImages: Long): Long {
        return personDB.addPerson(
            PersonRecord(
                personName = name,
                numImages = numImages,
                addTime = System.currentTimeMillis()
            )
        )
    }

    fun searchNameExistingShouldNotAdd(name: String): Boolean {
        return personDB.searchExistingPerson(name)
    }

    fun removePerson(id: Long) {
        personDB.removePerson(id)
    }

    fun getAll(): Flow<List<PersonRecord>> = personDB.getAll()

    fun getCount(): Long = personDB.getCount()
}
