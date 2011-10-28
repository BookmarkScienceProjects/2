#ifndef OMF_EXPORT_H
#define OMF_EXPORT_H

#include <ostream>

#include "matrix/VectorMatrix.h"
#include "OMFHeader.h"

void writeOMF(const std::string &path, OMFHeader &header, const VectorMatrix &field, OMFFormat format);
void writeOMF(std::ostream &out,       OMFHeader &header, const VectorMatrix &field, OMFFormat format);

#endif

