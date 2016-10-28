"""Add a column chartPatternSignal

Revision ID: dcbecbd633
Revises: 32a51c34353e
Create Date: 2015-10-19 18:49:27.432085

"""

# revision identifiers, used by Alembic.
revision = 'dcbecbd633'
down_revision = '32a51c34353e'
branch_labels = None
depends_on = None

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.add_column('chartPatternSignal', sa.Column('upDownFlag', sa.String(10)))


def downgrade():
    op.drop_column('chartPatternSignal', 'upDownFlag')
