"""create stock signal

Revision ID: 1498c821e325
Revises: 3986dff3fd19
Create Date: 2015-07-14 14:36:18.680000

"""

# revision identifiers, used by Alembic.
revision = '1498c821e325'
down_revision = '3986dff3fd19'
branch_labels = None
depends_on = None

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.create_table(
        'stockSignal',
        sa.Column('id', sa.Integer, primary_key=True),
        sa.Column('patternId', sa.Integer, sa.ForeignKey('patternMaster.id'), nullable=False),
        sa.Column('stockCode', sa.String(5), nullable=False),
        sa.Column('startDate', sa.TIMESTAMP),
        sa.Column('endDate', sa.TIMESTAMP)
    )


def downgrade():
    op.drop_table('stockSignal')
