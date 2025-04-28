package com.example.db

class ImagesVectorDB {

    private val imagesBox = ObjectBoxStore.store.boxFor(FaceImageRecord::class.java)

    fun addFaceImageRecord(record: FaceImageRecord): Long {
      return  imagesBox.put(record)
    }

    fun getNearestEmbeddingPersonName(embedding: FloatArray): FaceImageRecord? {
        /*
        Use maxResultCount to set the maximum number of objects to return by the ANN condition.
        Hint: it can also be used as the "ef" HNSW parameter to increase the search quality in combination
        with a query limit. For example, use maxResultCount of 100 with a Query limit of 10 to have 10 results
        that are of potentially better quality than just passing in 10 for maxResultCount
        (quality/performance tradeoff).
         */
        return imagesBox
            .query(FaceImageRecord_.faceEmbedding.nearestNeighbors(embedding, 10))
            .build()
            .findWithScores()
            .map { it.get() }
            .firstOrNull()
    }

    fun searchExistingFaceImageRecord(personID: Long): Boolean {
        return imagesBox.query(FaceImageRecord_.personID.equal(personID)).build().findFirst() != null
    }
    fun getPersonImage(personID: Long): FaceImageRecord? {
       return imagesBox.get(personID)
    }

    fun removeFaceImageRecord(personID: Long) {
        imagesBox.removeByIds(listOf(personID))
    }

    fun existingFaceNameNotStored(personName: String): Boolean {
        return imagesBox.query(FaceImageRecord_.personName.equal(personName)).build().findFirst() == null
    }

    fun getAllFaceRecords(): List<FaceImageRecord> {
        return imagesBox.all
    }


//    fun removeFaceRecordsWithPersonID(faceEmbedding:  FloatArray) {
//        imagesBox.removeByIds(
//            imagesBox.query(FaceImageRecord_.faceEmbedding.equal(faceEmbedding)).build().findIds().toList()
//        )
//    }
}
