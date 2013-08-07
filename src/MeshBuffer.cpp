
#include "MeshBuffer.hpp"


namespace aluminum {
    
    
    void MeshBuffer::draw() {
        
#ifdef BUILD_IOS
        glBindVertexArrayOES( vao[0] ); {
            
            if (useIndices) {
                glDrawElements(GL_TRIANGLES, (GLsizei) data.indices().size(), GL_UNSIGNED_INT, 0);
            } else {
                glDrawArrays(GL_TRIANGLES, 0, (GLsizei) data.vertices().size() * 9 ); //double check this!
                //printf("here...\n");
            }
        
        } glBindVertexArrayOES(0); {
        
            if (useIndices) {
                glDrawElements(GL_TRIANGLES, (GLsizei) data.indices().size(), GL_UNSIGNED_INT, 0);
            } else {
                glDrawArrays(GL_TRIANGLES, 0, (GLsizei) data.vertices().size() * 9 ); //double check this!
                //printf("here...\n");
            }
        } glBindVertexArrayOES(0);
        
#else
        glBindVertexArray( vao[0] );
        {
            if (useIndices) {
                glDrawElements(GL_TRIANGLES, (GLsizei) data.indices().size(), GL_UNSIGNED_INT, 0);
            } else {
                glDrawArrays(GL_TRIANGLES, 0, (GLsizei) data.vertices().size() * 9 ); //double check this!
                //printf("here...\n");
            }
        } glBindVertexArray(0); {
            if (useIndices) {
                glDrawElements(GL_TRIANGLES, (GLsizei) data.indices().size(), GL_UNSIGNED_INT, 0);
            } else {
                glDrawArrays(GL_TRIANGLES, 0, (GLsizei) data.vertices().size() * 9 ); //double check this!
                //printf("here...\n");
            }
        } glBindVertexArray(0);
        
#endif
        
    }
    
    
    void MeshBuffer::drawLines() {
        
#ifdef BUILD_IOS
        /*
         glBindVertexArrayOES( vao[0] );
         {
         if (useIndices) {
         glDrawElements(GL_TRIANGLES, (GLsizei) data.indices().size(), GL_UNSIGNED_INT, 0);
         } else {
         glDrawArrays(GL_TRIANGLES, 0, (GLsizei) data.vertices().size() * 9 ); //double check this!
         //printf("here...\n");
         }
         } glBindVertexArrayOES(0); {
         if (useIndices) {
         glDrawElements(GL_TRIANGLES, (GLsizei) data.indices().size(), GL_UNSIGNED_INT, 0);
         } else {
         glDrawArrays(GL_TRIANGLES, 0, (GLsizei) data.vertices().size() * 9 ); //double check this!
         //printf("here...\n");
         }
         } glBindVertexArrayOES(0);
         */
        
#else
        
        glBindVertexArray( vao[0] );
        {
            if (useIndices) {
                glDrawElements(GL_LINES, (GLsizei) data.indices().size(), GL_UNSIGNED_INT, 0);
            } else {
                //glDrawArrays(GL_LINES, 0, (GLsizei) data.vertices().size() * 7 ); //double check this!
                //printf("A here...\n");
            }
        }
        
        /*
        glBindVertexArray(0); {
            if (useIndices) {
                glDrawElements(GL_LINES, (GLsizei) data.indices().size(), GL_UNSIGNED_INT, 0);
            } else {
                glDrawArrays(GL_LINES, 0, (GLsizei) data.vertices().size() * 7 ); //double check this!
                printf("B here...\n");
            }
        } glBindVertexArray(0);
        */
#endif
        
    }
    
    
    
    
    void MeshBuffer::checkAttributes(int p, int n, int tc, int c) {
        if (p < 0) {
            printf("error : must have a vertex location...\n");
            exit(0);
        }
        
        useNormals = (n >= 0) ? true : false;
        useTexCoords = (tc >= 0) ? true : false;
        useColors = (c >= 0) ? true : false;
    }
    
    template<class T> void MeshBuffer::initVBO(GLuint vboID, int loc, int size, T b) {
        
        glBindBuffer( GL_ARRAY_BUFFER, vboID );
        glBufferData( GL_ARRAY_BUFFER, size * sizeof(float) * b.size(), NULL, GL_DYNAMIC_DRAW );
        glBufferData( GL_ARRAY_BUFFER, size * sizeof(float) * b.size(), &(b[0]), GL_DYNAMIC_DRAW );
        
        glEnableVertexAttribArray( loc );
       // glVertexAttribPointer( loc, 3, GL_FLOAT, GL_FALSE, 0, 0);
        glVertexAttribPointer( loc, size, GL_FLOAT, GL_FALSE, 0, 0);
        
    }
    
    void MeshBuffer::initIBO() {
        
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo[0]);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLint) * data.indices().size(), NULL, GL_DYNAMIC_DRAW);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLint) * data.indices().size(), &(data.indices()[0]), GL_DYNAMIC_DRAW);
        useIndices = true;
    }
    
    
    
    
    MeshBuffer MeshBuffer::update(MeshData _data, int p, int n, int tc, int c) {
        data = _data;
        
#ifdef BUILD_IOS
        glBindVertexArrayOES( vao[0] ); {
#else
            glBindVertexArray( vao[0] ); {
#endif
                checkAttributes(p, n, tc, c);
                
                //printf("vbo[0] = %d\n", vbo[0]);
                initVBO(vbo[0], p, 3, data.vertices());
                
                if (useNormals) {
                    initVBO(vbo[1], n, 3, data.normals());
                }
                
                if (useTexCoords) {
                    initVBO(vbo[2], tc, 3, data.texCoords());
                }
                
                if (useColors) {
                    initVBO(vbo[3], c, 4, data.colors());
                }
                
                if (data.indices().size() > 0) {
                    //printf("initting ibo\n");
                    initIBO();
                }
                
            }
            
#ifdef BUILD_IOS
            glBindVertexArrayOES(0);
#else
            glBindVertexArray(0);
#endif
            return *this;
        }
        
        MeshBuffer MeshBuffer::init(MeshData _data, int p, int n, int tc, int c) {
            //MeshBuffer MeshBuffer::init(MeshData &_data, int p, int n, int tc, int c) {
            
#ifdef BUILD_IOS
            glGenVertexArraysOES( 1, vao );
#else
            glGenVertexArrays( 1, vao );
#endif
            glGenBuffers(4, vbo);
            glGenBuffers(1, ibo);
            
            return update(_data, p, n, tc, c);
        }
        
        
    } // al::
